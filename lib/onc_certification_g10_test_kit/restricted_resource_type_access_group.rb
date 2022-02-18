require_relative 'restricted_access_test'

module ONCCertificationG10TestKit
  class RestrictedResourceTypeAccessGroup < Inferno::TestGroup
    title 'Restricted Resource Type Access'
    description %(
      This test ensures that patients are able to grant or deny access to a
      subset of resources to an app as requied by the certification criteria.
      The tester provides a list of resources that will be granted during the
      SMART App Launch process, and this test verifies that the scopes granted
      are consistent with what the tester provided. It also formulates queries
      to ensure that the app is either given access to, or denied access to, the
      appropriate resource types based on those chosen by the tester.

      Resources that can be mapped to USCDI are checked in this test, including:

        * AllergyIntolerance
        * CarePlan
        * CareTeam
        * Condition
        * Device
        * DiagnosticReport
        * DocumentReference
        * Goal
        * Immunization
        * MedicationRequest
        * Observation
        * Procedure

      For each of the resources that can be mapped to USCDI data class or
      elements, this set of tests performs a minimum number of requests to
      determine if access to the resource type is appropriately allowed or
      denied given the scope granted. In the case of the Patient resource, this
      test simply performs a read request. For other resources, it performs a
      search by patient that must be supported by the server. In some cases,
      servers can return an error message if a status search parameter is not
      provided. For these, the test will perform an additional search with the
      required status search parameter.

      This set of tests does not attempt to access resources that do not
      directly map to USCDI v1, including Encounter, Location, Organization, and
      Practitioner. It also does not test Provenance, as this resource type is
      accessed by queries through other resource types. These resource types are
      accessed in the more comprehensive Single Patient Query tests.

      If the tester chooses to not grant access to a resource, the queries
      associated with that resource must result in either a 401 (Unauthorized)
      or 403 (Forbidden) status code. The flexiblity provided here is due to
      some ambiguity in the specifications tested.
    )
    id :g10_restricted_resource_type_access

    input :url, :patient_id, :received_scopes, :expected_resources
    input :smart_credentials, type: :oauth_credentials

    config(
      inputs: {
        client_id: {
          default: 'SAMPLE_CONFIDENTIAL_CLIENT_ID'
        },
        client_secret: {
          optional: false,
          default: 'SAMPLE_CONFIDENTIAL_CLIENT_SECRET'
        }
      }
    )

    fhir_client do
      url :url
      oauth_credentials :smart_credentials
    end

    test from: :g10_restricted_access_test do
      title 'Access to Patient resources are restricted properly based on patient-selected scope'
      description %(
        This test ensures that access to the Patient is granted or
        denied based on the selection by the tester prior to the execution of
        the test. If the tester indicated that access will be granted to this
        resource, this test verifies that a search by patient in this resource
        does not result in an access denied result. If the tester indicated that
        access will be denied for this resource, this verifies that search by
        patient in the resource results in an access denied result.
      )
      id :g10_patient_restricted_access

      def resource_group
        USCore::PatientGroup
      end
    end

    test from: :g10_restricted_access_test do
      title 'Access to AllergyIntolerance resources are restricted properly based on patient-selected scope'
      description %(
        This test ensures that access to the AllergyIntolerance is granted or
        denied based on the selection by the tester prior to the execution of
        the test. If the tester indicated that access will be granted to this
        resource, this test verifies that a search by patient in this resource
        does not result in an access denied result. If the tester indicated that
        access will be denied for this resource, this verifies that search by
        patient in the resource results in an access denied result.
      )
      id :g10_allergy_intolerance_restricted_access

      def resource_group
        USCore::AllergyIntoleranceGroup
      end
    end

    test from: :g10_restricted_access_test do
      title 'Access to CarePlan resources are restricted properly based on patient-selected scope'
      description %(
        This test ensures that access to the CarePlan is granted or
        denied based on the selection by the tester prior to the execution of
        the test. If the tester indicated that access will be granted to this
        resource, this test verifies that a search by patient in this resource
        does not result in an access denied result. If the tester indicated that
        access will be denied for this resource, this verifies that search by
        patient in the resource results in an access denied result.
      )
      id :g10_care_plan_restricted_access

      def resource_group
        USCore::CarePlanGroup
      end
    end

    test from: :g10_restricted_access_test do
      title 'Access to CareTeam resources are restricted properly based on patient-selected scope'
      description %(
        This test ensures that access to the CareTeam is granted or
        denied based on the selection by the tester prior to the execution of
        the test. If the tester indicated that access will be granted to this
        resource, this test verifies that a search by patient in this resource
        does not result in an access denied result. If the tester indicated that
        access will be denied for this resource, this verifies that search by
        patient in the resource results in an access denied result.
      )
      id :g10_care_team_restricted_access

      def resource_group
        USCore::CareTeamGroup
      end
    end

    test from: :g10_restricted_access_test do
      title 'Access to Condition resources are restricted properly based on patient-selected scope'
      description %(
        This test ensures that access to the Condition is granted or
        denied based on the selection by the tester prior to the execution of
        the test. If the tester indicated that access will be granted to this
        resource, this test verifies that a search by patient in this resource
        does not result in an access denied result. If the tester indicated that
        access will be denied for this resource, this verifies that search by
        patient in the resource results in an access denied result.
      )
      id :g10_condition_restricted_access

      def resource_group
        USCore::ConditionGroup
      end
    end

    test from: :g10_restricted_access_test do
      title 'Access to Device resources are restricted properly based on patient-selected scope'
      description %(
        This test ensures that access to the Device is granted or
        denied based on the selection by the tester prior to the execution of
        the test. If the tester indicated that access will be granted to this
        resource, this test verifies that a search by patient in this resource
        does not result in an access denied result. If the tester indicated that
        access will be denied for this resource, this verifies that search by
        patient in the resource results in an access denied result.
      )
      id :g10_device_restricted_access

      def resource_group
        USCore::DeviceGroup
      end
    end

    test from: :g10_restricted_access_test do
      title 'Access to DiagnosticReport resources are restricted properly based on patient-selected scope'
      description %(
        This test ensures that access to the DiagnosticReport is granted or
        denied based on the selection by the tester prior to the execution of
        the test. If the tester indicated that access will be granted to this
        resource, this test verifies that a search by patient in this resource
        does not result in an access denied result. If the tester indicated that
        access will be denied for this resource, this verifies that search by
        patient in the resource results in an access denied result.
      )
      id :g10_diagnostic_report_restricted_access

      def resource_group
        USCore::DiagnosticReportLabGroup
      end
    end

    test from: :g10_restricted_access_test do
      title 'Access to DocumentReference resources are restricted properly based on patient-selected scope'
      description %(
        This test ensures that access to the DocumentReference is granted or
        denied based on the selection by the tester prior to the execution of
        the test. If the tester indicated that access will be granted to this
        resource, this test verifies that a search by patient in this resource
        does not result in an access denied result. If the tester indicated that
        access will be denied for this resource, this verifies that search by
        patient in the resource results in an access denied result.
      )
      id :g10_document_reference_restricted_access

      def resource_group
        USCore::DocumentReferenceGroup
      end
    end

    test from: :g10_restricted_access_test do
      title 'Access to Goal resources are restricted properly based on patient-selected scope'
      description %(
        This test ensures that access to the Goal is granted or
        denied based on the selection by the tester prior to the execution of
        the test. If the tester indicated that access will be granted to this
        resource, this test verifies that a search by patient in this resource
        does not result in an access denied result. If the tester indicated that
        access will be denied for this resource, this verifies that search by
        patient in the resource results in an access denied result.
      )
      id :g10_goal_restricted_access

      def resource_group
        USCore::GoalGroup
      end
    end

    test from: :g10_restricted_access_test do
      title 'Access to Immunization resources are restricted properly based on patient-selected scope'
      description %(
        This test ensures that access to the Immunization is granted or
        denied based on the selection by the tester prior to the execution of
        the test. If the tester indicated that access will be granted to this
        resource, this test verifies that a search by patient in this resource
        does not result in an access denied result. If the tester indicated that
        access will be denied for this resource, this verifies that search by
        patient in the resource results in an access denied result.
      )
      id :g10_immunization_restricted_access

      def resource_group
        USCore::ImmunizationGroup
      end
    end

    test from: :g10_restricted_access_test do
      title 'Access to MedicationRequest resources are restricted properly based on patient-selected scope'
      description %(
        This test ensures that access to the MedicationRequest is granted or
        denied based on the selection by the tester prior to the execution of
        the test. If the tester indicated that access will be granted to this
        resource, this test verifies that a search by patient in this resource
        does not result in an access denied result. If the tester indicated that
        access will be denied for this resource, this verifies that search by
        patient in the resource results in an access denied result.
      )
      id :g10_medication_request_access

      def resource_group
        USCore::MedicationRequestGroup
      end
    end

    test from: :g10_restricted_access_test do
      title 'Access to Observation resources are restricted properly based on patient-selected scope'
      description %(
        This test ensures that access to the Observation is granted or
        denied based on the selection by the tester prior to the execution of
        the test. If the tester indicated that access will be granted to this
        resource, this test verifies that a search by patient in this resource
        does not result in an access denied result. If the tester indicated that
        access will be denied for this resource, this verifies that search by
        patient in the resource results in an access denied result.
      )
      id :g10_observation_restricted_access

      def resource_group
        USCore::PulseOximetryGroup
      end
    end

    test from: :g10_restricted_access_test do
      title 'Access to Procedure resources are restricted properly based on patient-selected scope'
      description %(
        This test ensures that access to the Procedure is granted or
        denied based on the selection by the tester prior to the execution of
        the test. If the tester indicated that access will be granted to this
        resource, this test verifies that a search by patient in this resource
        does not result in an access denied result. If the tester indicated that
        access will be denied for this resource, this verifies that search by
        patient in the resource results in an access denied result.
      )
      id :g10_procedure_restricted_access

      def resource_group
        USCore::ProcedureGroup
      end
    end
  end
end
