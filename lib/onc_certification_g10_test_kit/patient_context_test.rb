module G10CertificationTestKit
  class PatientContextTest < Inferno::Test
    title 'OAuth token exchange response body contains patient context and patient resource can be retrieved'
    description %(
      The `patient` field is a String value with a patient id, indicating that
      the app was launched in the context of this FHIR Patient.
    )
    id :g10_patient_context
    input :patient_id, :url
    input :smart_credentials, type: :oauth_credentials

    fhir_client :authenticated do
      url :url
      oauth_credentials :smart_credentials
    end

    run do
      skip_if smart_credentials.access_token.blank?, 'No access token was received during the SMART launch'

      skip_if patient_id.blank?, 'Token response did not contain `patient` field'

      skip_if request.status != 200, 'Token was not successfully refreshed' if config.options[:refresh_test]

      fhir_read(:patient, patient_id, client: :authenticated)

      assert_response_status(200)
      assert_resource_type(:patient)
    end
  end
end
