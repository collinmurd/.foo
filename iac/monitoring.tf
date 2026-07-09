# Monitoring: OCI APM + OCI Notifications
#
# Provides:
#   - APM domain (Always Free) for synthetic monitoring and future OTEL ingestion
#   - HTTPS synthetic monitor for collinandalivia.com (checks every 5 minutes)
#   - OCI Notifications topic + email subscription for alerts
#   - OCI Monitoring alarm that fires when availability drops below 100%
#
# Future OTEL instrumentation: point your app's OTEL exporter at
# oci_apm_apm_domain.main.data_upload_endpoint using the APM private data key.

# ---------------------------------------------------------------------------
# APM Domain (Always Free)
# ---------------------------------------------------------------------------

resource "oci_apm_apm_domain" "main" {
  compartment_id = var.compartment_id
  display_name   = var.apm_domain_display_name
  description    = "Site monitoring and OTEL instrumentation for collinandalivia.com"
  is_free_tier   = true
}

# ---------------------------------------------------------------------------
# Synthetic monitor vantage points
# ---------------------------------------------------------------------------

data "oci_apm_synthetics_public_vantage_points" "chicago" {
  apm_domain_id = oci_apm_apm_domain.main.id
  name          = "OraclePublic-us-chicago-1"
}

# ---------------------------------------------------------------------------
# HTTPS synthetic monitor — collinandalivia.com
# ---------------------------------------------------------------------------

resource "oci_apm_synthetics_monitor" "collinandalivia_com" {
  apm_domain_id              = oci_apm_apm_domain.main.id
  display_name               = "collinandalivia-https"
  monitor_type               = "REST"
  repeat_interval_in_seconds = 360 # 6 minutes (minimum allowed for free tier non-external vantage synthetic)
  status                     = "ENABLED"
  target                     = "https://collinandalivia.com"
  timeout_in_seconds         = 30

  vantage_points {
    name = data.oci_apm_synthetics_public_vantage_points.chicago.public_vantage_point_collection[0].items[0].name
  }

  configuration {
    config_type                       = "REST_CONFIG"
    is_certificate_validation_enabled = true
    is_failure_retried                = false
    is_redirection_enabled            = true
    request_method                    = "GET"
    verify_response_codes             = ["200"]

    network_configuration {
      protocol   = "TCP"
      probe_mode = "SACK"
    }
  }

  availability_configuration {
    max_allowed_failures_per_interval = 0
    min_allowed_runs_per_interval     = 1
  }
}

# ---------------------------------------------------------------------------
# OCI Notifications — alert topic and email subscription
# ---------------------------------------------------------------------------

resource "oci_ons_notification_topic" "site_alerts" {
  compartment_id = var.compartment_id
  name           = "site-monitoring-alerts"
  description    = "Alerts for collinandalivia.com site health"
}

resource "oci_ons_subscription" "alert_email" {
  compartment_id = var.compartment_id
  topic_id       = oci_ons_notification_topic.site_alerts.topic_id
  protocol       = "EMAIL"
  endpoint       = var.alert_email
}

resource "oci_ons_subscription" "alert_sms" {
  count = var.alert_phone != null ? 1 : 0

  compartment_id = var.compartment_id
  topic_id       = oci_ons_notification_topic.site_alerts.topic_id
  protocol       = "SMS"
  endpoint       = var.alert_phone
}

# ---------------------------------------------------------------------------
# OCI Monitoring alarm — fires when site availability < 100%
# ---------------------------------------------------------------------------

resource "oci_monitoring_alarm" "site_down" {
  compartment_id        = var.compartment_id
  display_name          = "collinandalivia.com - Site Down"
  is_enabled            = true
  metric_compartment_id = var.compartment_id
  namespace             = "oracle_apm_synthetics"
  severity              = "CRITICAL"
  destinations          = [oci_ons_notification_topic.site_alerts.topic_id]
  message_format        = "ONS_OPTIMIZED"

  # Fires if any check in the window reports < 100% availability.
  # Window (10m) must be longer than the check interval (6m) so every
  # evaluation always contains at least one data point. A window shorter
  # than the check interval leaves gaps where OCI sees no data and holds
  # the alarm FIRING even after the site recovers.
  query = "Availability[5m].mean() < 1"

  # Fire on the first failing evaluation (within ~1-2 minutes of a failure).
  pending_duration = "PT1M"

  # Re-notify every hour while the site remains down
  repeat_notification_duration = "PT1H"

  notification_title = "collinandalivia.com is unreachable"
  body               = "The synthetic health check for https://collinandalivia.com has failed. Verify the server is running and reachable."
}
