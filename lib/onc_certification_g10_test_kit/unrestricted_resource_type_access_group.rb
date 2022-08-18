require_relative 'resource_access_test'

module ONCCertificationG10TestKit
  class UnrestrictedResourceTypeAccessGroup < Inferno::TestGroup
    title 'Unrestricted Resource Type Access'
    description %(
      This test ensures that apps have full access to USCDI resources if granted
      access by the tester. The tester must grant access to the following
      resources during the SMART Launch process, and this test ensures they all
      can be accessed:

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
        * Patient
        * Provenance
        * Encounter
        * Practitioner
        * Organization

      If testing against USCDI v2, ServiceRequest is also checked.

      For each of the resource types that can be mapped to USCDI data class or
      elements, this set of tests performs a minimum number of requests to
      determine that the resource type can be accessed given the scope granted.
      In the case of the Patient resource, this test simply performs a read
      request. For other resources, it performs a search by patient that must be
      supported by the server. In some cases, servers can return an error
      message if a status search parameter is not provided. For these, the test
      will perform an additional search with the required status search
      parameter.

      This set of tests does not attempt to access resources that do not
      directly map to USCDI. For USCDI v1 this includes:

        * Encounter
        * Location
        * Organization
        * Practitioner

      For USCDI v2 this includes:

        * Location
        * Organization
        * Practitioner

      It also does not test Provenance, as this resource type is accessed by
      queries through other resource types. These resources types are accessed
      in the more comprehensive Single Patient Query tests.

      However, the authorization system must indicate that access is granted to
      the Encounter, Practitioner and Organization resource types by providing
      them in the returned scopes because they are required to support the read
      interaction.
    )
    id :g10_unrestricted_resource_type_access

    input :url, :smart_credentials, :patient_id, :received_scopes
    input :smart_credentials, type: :oauth_credentials

    fhir_client do
      url :url
      oauth_credentials :smart_credentials
    end

    ALL_RESOURCES =
      [
        'AllergyIntolerance',
        'CarePlan',
        'CareTeam',
        'Condition',
        'Device',
        'DiagnosticReport',
        'DocumentReference',
        'Goal',
        'Immunization',
        'MedicationRequest',
        'Observation',
        'Procedure',
        'Patient',
        'Provenance',
        'Encounter',
        'Practitioner',
        'Organization'
      ].freeze

    V5_ALL_RESOURCES = (ALL_RESOURCES + ['ServiceRequest']).freeze

    NON_PATIENT_COMPARTMENT_RESOURCES =
      [
        'Encounter',
        'Device',
        'Location',
        'Medication',
        'Organization',
        'Practitioner',
        'PractitionerRole',
        'RelatedPerson'
      ].freeze

    V5_NON_PATIENT_COMPARTMENT_RESOURCES =
      (NON_PATIENT_COMPARTMENT_RESOURCES - ['Encounter'] + ['ServiceRequest']).freeze

    test do
      title 'Scope granted enables access to all US Core resource types.'
      description %(
        This test confirms that the scopes granted during authorization are
        sufficient to access all relevant US Core resources.
      )

      def all_resources
        return V5_ALL_RESOURCES if suite_options[:us_core_version] == 'us_core_5'

        ALL_RESOURCES
      end

      def non_patient_compartment_resources
        return V5_NON_PATIENT_COMPARTMENT_RESOURCES if suite_options[:us_core_version] == 'us_core_5'

        NON_PATIENT_COMPARTMENT_RESOURCES
      end

      def scope_granting_access?(resource_type)
        received_scopes.split.find do |scope|
          return true if non_patient_compartment_resources.include?(resource_type) &&
                         ["user/#{resource_type}.read", "user/#{resource_type}.*"].include?(scope)

          [
            'patient/*.read',
            'patient/*.*',
            "patient/#{resource_type}.read",
            "patient/#{resource_type}.*"
          ].include?(scope)
        end
      end

      run do
        skip_if received_scopes.blank?, 'A list of granted scopes was not provided to this test as required.'

        allowed_resources = all_resources.select { |resource_type| scope_granting_access?(resource_type) }
        denied_resources = all_resources - allowed_resources

        assert denied_resources.empty?, %(
          This test requires access to all US Core resources with patient
          information, but the received scope:



          `#{received_scopes}`



          does not grant access to the `#{denied_resources.join(', ')}` resource
          type(s).
        )

        pass 'Scopes received indicate access to all necessary resources.'
      end
    end

    test from: :g10_resource_access_test do
      title 'Access to Patient resources granted'
      description %(
        This test ensures that access to the Patient is granted.
      )
      id :g10_patient_unrestricted_access

      def resource_group
        USCoreTestKit::USCoreV311::PatientGroup
      end
    end

    test from: :g10_resource_access_test do
      title 'Access to AllergyIntolerance resources granted'
      description %(
        This test ensures that access to the AllergyIntolerance is granted.
      )
      id :g10_allergy_intolerance_unrestricted_access

      def resource_group
        USCoreTestKit::USCoreV311::AllergyIntoleranceGroup
      end
    end

    test from: :g10_resource_access_test do
      title 'Access to CarePlan resources granted'
      description %(
        This test ensures that access to the CarePlan is granted.
      )
      id :g10_care_plan_unrestricted_access

      def resource_group
        USCoreTestKit::USCoreV311::CarePlanGroup
      end
    end

    test from: :g10_resource_access_test do
      title 'Access to CareTeam resources granted'
      description %(
        This test ensures that access to the CareTeam is granted.
      )
      id :g10_care_team_unrestricted_access

      def resource_group
        USCoreTestKit::USCoreV311::CareTeamGroup
      end
    end

    test from: :g10_resource_access_test do
      title 'Access to Condition resources granted'
      description %(
        This test ensures that access to the Condition is granted.
      )
      id :g10_condition_unrestricted_access

      def resource_group
        USCoreTestKit::USCoreV311::ConditionGroup
      end
    end

    test from: :g10_resource_access_test do
      title 'Access to Device resources granted'
      description %(
        This test ensures that access to the Device is granted.
      )
      id :g10_device_unrestricted_access

      def resource_group
        USCoreTestKit::USCoreV311::DeviceGroup
      end
    end

    test from: :g10_resource_access_test do
      title 'Access to DiagnosticReport resources granted'
      description %(
        This test ensures that access to the DiagnosticReport is granted.
      )
      id :g10_diagnostic_report_unrestricted_access

      def resource_group
        USCoreTestKit::USCoreV311::DiagnosticReportLabGroup
      end
    end

    test from: :g10_resource_access_test do
      title 'Access to DocumentReference resources granted'
      description %(
        This test ensures that access to the DocumentReference is granted.
      )
      id :g10_document_reference_unrestricted_access

      def resource_group
        USCoreTestKit::USCoreV311::DocumentReferenceGroup
      end
    end

    test from: :g10_resource_access_test do
      title 'Access to Goal resources granted'
      description %(
        This test ensures that access to the Goal is granted.
      )
      id :g10_goal_unrestricted_access

      def resource_group
        USCoreTestKit::USCoreV311::GoalGroup
      end
    end

    test from: :g10_resource_access_test do
      title 'Access to Immunization resources granted'
      description %(
        This test ensures that access to the Immunization is granted.
      )
      id :g10_immunization_unrestricted_access

      def resource_group
        USCoreTestKit::USCoreV311::ImmunizationGroup
      end
    end

    test from: :g10_resource_access_test do
      title 'Access to MedicationRequest resources granted'
      description %(
        This test ensures that access to the MedicationRequest is granted.
      )
      id :g10_medication_request_access

      def resource_group
        USCoreTestKit::USCoreV311::MedicationRequestGroup
      end
    end

    test from: :g10_resource_access_test do
      title 'Access to Observation resources granted'
      description %(
        This test ensures that access to the Observation is granted.
      )
      id :g10_observation_unrestricted_access

      def resource_group
        USCoreTestKit::USCoreV311::PulseOximetryGroup
      end
    end

    test from: :g10_resource_access_test do
      title 'Access to Procedure resources granted'
      description %(
        This test ensures that access to the Procedure is granted.
      )
      id :g10_procedure_unrestricted_access

      def resource_group
        USCoreTestKit::USCoreV311::ProcedureGroup
      end
    end

    if Feature.us_core_v4?
      test from: :g10_resource_access_test do
        title 'Access to Encounter resources granted'
        description %(
          This test ensures that access to the Encounter is granted.
        )
        id :g10_encounter_unrestricted_access

        required_suite_options us_core_version: 'us_core_5'

        def resource_group
          USCoreTestKit::USCoreV501::EncounterGroup
        end
      end

      test from: :g10_resource_access_test do
        title 'Access to ServiceRequest resources granted'
        description %(
          This test ensures that access to the ServiceRequest is granted.
        )
        id :g10_service_request_unrestricted_access

        required_suite_options us_core_version: 'us_core_5'

        def resource_group
          USCoreTestKit::USCoreV501::ServiceRequestGroup
        end
      end
    end
  end
end
