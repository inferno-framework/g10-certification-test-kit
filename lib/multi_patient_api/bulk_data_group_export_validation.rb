require 'pry' #TODO: Remove
module MultiPatientAPI
  class BulkDataGroupExportValidation < Inferno::TestGroup
    title 'Group Compartment Export Validation Tests'
    description <<~DESCRIPTION
      Verify that Group compartment export from the Bulk Data server follow US Core Implementation Guide
    DESCRIPTION

    id :bulk_data_group_export_validation

    input :bulk_status_output, :requires_access_token, :bulk_access_token

    http_client :ndjson_endpoint do
      url :output_endpoint
    end 

    # TODO: Create after implementing TLS Tester Class.
    test do
      title 'Bulk Data Server is secured by transport layer security'
      description <<~DESCRIPTION
        [§170.315(g)(10) Test Procedure](https://www.healthit.gov/test-method/standardized-api-patient-and-population-services) requires that
        all exchanges described herein between a client and a server SHALL be secured using Transport Layer Security (TLS) Protocol Version 1.2 (RFC5246).
      DESCRIPTION
      # link 'http://hl7.org/fhir/uv/bulkdata/export/index.html#security-considerations'

      run {
        
      }
    end

    test do
      title 'NDJSON download requires access token if requireAccessToken is true'
      description <<~DESCRIPTION
        If the requiresAccessToken field in the Complete Status body is set to true, the request SHALL include a valid access token.

        [FHIR R4 Security](http://build.fhir.org/security.html#AccessDenied) and
        [The OAuth 2.0 Authorization Framework: Bearer Token Usage](https://tools.ietf.org/html/rfc6750#section-3.1)
        recommend using HTTP status code 401 for invalid token but also allow the actual result be controlled by policy and context.
      DESCRIPTION
      # link 'http://hl7.org/fhir/uv/bulkdata/export/index.html#file-request'

      input :requires_access_token, :bulk_status_output, :bulk_access_token

      run {
        skip 'Could not verify this functionality when requiresAccessToken is not provided' unless requires_access_token.present?
        skip 'Could not verify this functionality when requireAccessToken is false' unless requires_access_token
        skip 'Could not verify this functionality when bulk_status_output is not provided' unless bulk_status_output.present? 


        output_endpoint = JSON.parse(bulk_status_output)[0]['url']
        get_file(output_endpoint, false)

        # assert_response_bad_or_unauthorized TODO: Uncomment this following changes implemented in core.
      }
    end

    test do
      title 'Patient resources returned conform to the US Core Patient Profile'
      description <<~DESCRIPTION
        This test verifies that the resources returned from bulk data export conform to the US Core profiles. This includes checking for missing data elements and value set verification.
      DESCRIPTION
      # link 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient'

      run {
        skip 'Could not verify this functionality when bulk_status_output is not provided' unless bulk_status_output.present?
        skip 'Could not verify this functionality when requires_access_token is not set' unless requires_access_token.present?
        skip 'Could not verify this functionality when remote_access_token is required and not provided' if requires_access_token && !bulk_access_token.present?

        metadata = USCore::PatientGroup::metadata

        profile_definitions = [
          {
            profile: metadata.profile_url,
            must_support_info: metadata.must_supports.deep_dup,
            binding_info: metadata.bindings.deep_dup
          }
        ]

        assert output_conforms_to_profile?('Patient', profile_definitions), 'Resource does not conform to profile.'
      }
    end

    test do
      title 'Group export has at least two patients'
      description <<~DESCRIPTION
        This test verifies that the Group export has at least two patients.
      DESCRIPTION
      # link 'http://ndjson.org/'

      run {
        skip 'No Patient resources processed from bulk data export.' unless @patient_ids_seen.present?

        assert @patient_ids_seen.length >= MIN_RESOURCE_COUNT, 'Bulk data export did not have multiple Patient resources'
      }
    end

    test do
      title 'Patient IDs match those expected in Group'
      description <<~DESCRIPTION
        This test checks that the list of patient IDs that are expected match those that are returned.
        If no patient ids are provided to the test, then the test will be omitted.
      DESCRIPTION
      # link 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient'

      input :bulk_patient_ids_in_group

      run {
        omit 'No patient ids were given.' unless bulk_patient_ids_in_group.present?

        expected_ids = Set.new(bulk_patient_ids_in_group.split(',').map(&:strip))

        assert @patient_ids_seen.sort == expected_ids.sort, "Mismatch between patient ids seen (#{@patient_ids_seen.to_a.join(', ')}) and patient ids expected (#{bulk_patient_ids_in_group})"
      }
    end

    test do
      title 'AllergyIntolerance resources returned conform to the US Core AllergyIntolerance Profile'
      description <<~DESCRIPTION
        This test verifies that the resources returned from bulk data export conform to the US Core profiles. This includes checking for missing data elements and value set verification.
      DESCRIPTION
      # link 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-allergyintolerance'

      input :bulk_status_output, :requires_access_token, :bulk_access_token

      run {
        metadata = USCore::AllergyIntoleranceGroup::metadata

        profile_definitions = [
          {
            profile: metadata.profile_url,
            must_support_info: metadata.must_supports.deep_dup,
            binding_info: metadata.bindings.deep_dup
          }
        ]

        assert output_conforms_to_profile?('AllergyIntolerance', profile_definitions), 'Resources do not conform to profile.'
      }
    end

    test do
      title 'CarePlan resources returned conform to the US Core CarePlan Profile'
      description <<~DESCRIPTION
        This test verifies that the resources returned from bulk data export conform to the US Core profiles. This includes checking for missing data elements and value set verification.
      DESCRIPTION
      # link 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-careplan'

      input :bulk_status_output, :requires_access_token, :bulk_access_token

      run {
        metadata = USCore::CarePlanGroup::metadata

        profile_definitions = [
          {
            profile: metadata.profile_url,
            must_support_info: metadata.must_supports.deep_dup,
            binding_info: metadata.bindings.deep_dup
          }
        ]

        assert output_conforms_to_profile?('CarePlan', profile_definitions), 'Resources do not conform to profile.'
      }
    end

    test do
      title 'CareTeam resources returned conform to the US Core CareTeam Profile'
      description <<~DESCRIPTION
        This test verifies that the resources returned from bulk data export conform to the US Core profiles. This includes checking for missing data elements and value set verification.
      DESCRIPTION
      # link 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-careteam'

      input :bulk_status_output, :requires_access_token, :bulk_access_token

      run {
        metadata = USCore::CareTeamGroup::metadata

        profile_definitions = [
          {
            profile: metadata.profile_url,
            must_support_info: metadata.must_supports.deep_dup,
            binding_info: metadata.bindings.deep_dup
          }
        ]

        assert output_conforms_to_profile?('CareTeam', profile_definitions), 'Resources do not conform to profile.'
      }
    end

    test do
      title 'Condition resources returned conform to the US Core Condition Profile'
      description <<~DESCRIPTION
        This test verifies that the resources returned from bulk data export conform to the US Core profiles. This includes checking for missing data elements and value set verification.
      DESCRIPTION
      # link 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-condition'

      run {
        metadata = USCore::ConditionGroup::metadata

        profile_definitions = [
          {
            profile: metadata.profile_url,
            must_support_info: metadata.must_supports.deep_dup,
            binding_info: metadata.bindings.deep_dup
          }
        ]

        assert output_conforms_to_profile?('Condition', profile_definitions), 'Resources do not conform to profile.'
      }
    end

    test do
      title 'Device resources returned conform to the US Core Implantable Device Profile'
      description <<~DESCRIPTION
        This test verifies that the resources returned from bulk data export conform to the US Core profiles. This includes checking for missing data elements and value set verification.
      DESCRIPTION
      # link 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-implantable-device'

      run {
        metadata = USCore::DeviceGroup::metadata

        profile_definitions = [
          {
            profile: metadata.profile_url,
            must_support_info: metadata.must_supports.deep_dup,
            binding_info: metadata.bindings.deep_dup
          }
        ]

        assert output_conforms_to_profile?('Device', profile_definitions), 'Resources do not conform to profile.'
      }
    end

    test do
      title 'DiagnosticReport resources returned conform to the US Core DiagnosticReport Profile'
      description <<~DESCRIPTION
        This test verifies that the resources returned from bulk data export conform to the following US Core profiles. This includes checking for missing data elements and value set verification.

        * http://hl7.org/fhir/us/core/StructureDefinition/us-core-diagnosticreport-lab
        * http://hl7.org/fhir/us/core/StructureDefinition/us-core-diagnosticreport-note
      DESCRIPTION
      # link 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-diagnosticreport-l'

      run {
        metadata_lab = USCore::DiagnosticReportLabGroup::metadata
        metadata_note = USCore::DiagnosticReportNoteGroup::metadata

        profile_definitions = [
          {
            profile: metadata_lab.profile_url,
            must_support_info: metadata_lab.must_supports.deep_dup,
            binding_info: metadata_lab.bindings.deep_dup
          }, 
          {
            profile: metadata_note.profile_url,
            must_support_info: metadata_note.must_supports.deep_dup,
            binding_info: metadata_note.bindings.deep_dup
          }
        ]

        assert output_conforms_to_profile?('DiagnosticReport', profile_definitions), 'Resources do not conform to profile.'
      }
    end

    test do
      title 'DocumentReference resources returned conform to the US Core DocumentReference Profile'
      description <<~DESCRIPTION
        This test verifies that the resources returned from bulk data export conform to the US Core profiles. This includes checking for missing data elements and value set verification.
      DESCRIPTION
      # link 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-documentreference'

      run {
        metadata = USCore::DocumentReferenceGroup::metadata

        profile_definitions = [
          {
            profile: metadata.profile_url,
            must_support_info: metadata.must_supports.deep_dup,
            binding_info: metadata.bindings.deep_dup
          }
        ]

        assert output_conforms_to_profile?('DocumentReference', profile_definitions), 'Resources do not conform to profile.'
      }
    end

    test do
      title 'Goal resources returned conform to the US Core Goal Profile'
      description <<~DESCRIPTION
        This test verifies that the resources returned from bulk data export conform to the US Core profiles. This includes checking for missing data elements and value set verification.
      DESCRIPTION
      # link 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-goal'

      run {
        metadata = USCore::GoalGroup::metadata

        profile_definitions = [
          {
            profile: metadata.profile_url,
            must_support_info: metadata.must_supports.deep_dup,
            binding_info: metadata.bindings.deep_dup
          }
        ]

        assert output_conforms_to_profile?('Goal', profile_definitions), 'Resources do not conform to profile.'
      }
    end

    test do
      title 'Immunization resources returned conform to the US Core Immunization Profile'
      description <<~DESCRIPTION
        This test verifies that the resources returned from bulk data export conform to the US Core profiles. This includes checking for missing data elements and value set verification.
      DESCRIPTION
      # link 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-Immunization'

      run {
        metadata = USCore::ImmunizationGroup::metadata

        profile_definitions = [
          {
            profile: metadata.profile_url,
            must_support_info: metadata.must_supports.deep_dup,
            binding_info: metadata.bindings.deep_dup
          }
        ]

        assert output_conforms_to_profile?('Immunization', profile_definitions), 'Resources do not conform to profile.'
      }
    end

    test do
      title 'MedicationRequest resources returned conform to the US Core MedicationRequest Profile'
      description <<~DESCRIPTION
        This test verifies that the resources returned from bulk data export conform to the US Core profiles. This includes checking for missing data elements and value set verification.
      DESCRIPTION
      # link 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-medicationrequest'

      run {
        metadata = USCore::MedicationRequestGroup::metadata

        profile_definitions = [
          {
            profile: metadata.profile_url,
            must_support_info: metadata.must_supports.deep_dup,
            binding_info: metadata.bindings.deep_dup
          }
        ]

        assert output_conforms_to_profile?('MedicationRequest', profile_definitions), 'Resources do not conform to profile.'
      }
    end

    test do
      title 'Observation resources returned conform to the US Core Observation Profile'
      description <<~DESCRIPTION
        This test verifies that the resources returned from bulk data
        export conform to the following US Core profiles. This includes
        checking for missing data elements and value set verification.

        * http://hl7.org/fhir/us/core/StructureDefinition/pediatric-bmi-for-age
        * http://hl7.org/fhir/us/core/StructureDefinition/pediatric-weight-for-height
        * http://hl7.org/fhir/us/core/StructureDefinition/us-core-observation-lab
        * http://hl7.org/fhir/us/core/StructureDefinition/us-core-pulse-oximetry
        * http://hl7.org/fhir/us/core/StructureDefinition/us-core-smokingstatus
        * http://hl7.org/fhir/us/core/StructureDefinition/head-occipital-frontal-circumference-percentile
        * http://hl7.org/fhir/StructureDefinition/bp
        * http://hl7.org/fhir/StructureDefinition/bodyheight
        * http://hl7.org/fhir/StructureDefinition/bodytemp
        * http://hl7.org/fhir/StructureDefinition/bodyweight
        * http://hl7.org/fhir/StructureDefinition/heartrate
        * http://hl7.org/fhir/StructureDefinition/resprate
      DESCRIPTION
      # link 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-observation-lab'

      run {
        metadatas = [ USCore::PediatricBmiForAgeGroup::metadata, USCore::PediatricWeightForHeightGroup::metadata,
                      USCore::ObservationLabGroup::metadata, USCore::PulseOximetryGroup::metadata, USCore::SmokingstatusGroup::metadata, 
                      USCore::HeadCircumferenceGroup::metadata, USCore::BpGroup::metadata, USCore::BodyheightGroup::metadata, 
                      USCore::BodytempGroup::metadata, USCore::BodyweightGroup::metadata, USCore::HeartrateGroup::metadata, 
                      USCore::ResprateGroup::metadata ]

        profile_definitions = []

        metadatas.each do |data|
          profile_definitions << {
            profile: data.profile_url,
            must_support_info: data.must_supports.deep_dup,
            binding_info: data.bindings.deep_dup
          }
        end 

        assert output_conforms_to_profile?('Observation', profile_definitions), 'Resources do not conform to profile.'
      }
    end

    test do
      title 'Procedure resources returned conform to the US Core Procedure Profile'
      description <<~DESCRIPTION
        This test verifies that the resources returned from bulk data export conform to the US Core profiles. This includes checking for missing data elements and value set verification.
      DESCRIPTION
      # link 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-procedure'

      run {
        metadata = USCore::ProcedureGroup::metadata

        profile_definitions = [
          {
            profile: metadata.profile_url,
            must_support_info: metadata.must_supports.deep_dup,
            binding_info: metadata.bindings.deep_dup
          }
        ]

        assert output_conforms_to_profile?('Procedure', profile_definitions), 'Resources do not conform to profile.'
      }
    end

    test do
      title 'Encounter resources returned conform to the US Core Encounter Profile'
      description <<~DESCRIPTION
        This test verifies that the resources returned from bulk data export conform to the US Core profiles. This includes checking for missing data elements and value set verification.
      DESCRIPTION
      # link 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-encounter'

      run {
        metadata = USCore::EncounterGroup::metadata

        profile_definitions = [
          {
            profile: metadata.profile_url,
            must_support_info: metadata.must_supports.deep_dup,
            binding_info: metadata.bindings.deep_dup
          }
        ]

        assert output_conforms_to_profile?('Encounter', profile_definitions), 'Resources do not conform to profile.'
      }
    end

    test do
      title 'Organization resources returned conform to the US Core Organization Profile'
      description <<~DESCRIPTION
        This test verifies that the resources returned from bulk data export conform to the US Core profiles. This includes checking for missing data elements and value set verification.
      DESCRIPTION
      # link 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-organization'

      run {
        metadata = USCore::OrganizationGroup::metadata

        profile_definitions = [
          {
            profile: metadata.profile_url,
            must_support_info: metadata.must_supports.deep_dup,
            binding_info: metadata.bindings.deep_dup
          }
        ]

        assert output_conforms_to_profile?('Organization', profile_definitions), 'Resources do not conform to profile.'
      }
    end

    test do
      title 'Practitioner resources returned conform to the US Core Practitioner Profile'
      description <<~DESCRIPTION
        This test verifies that the resources returned from bulk data export conform to the US Core profiles. This includes checking for missing data elements and value set verification.
      DESCRIPTION
      # link 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-practitioner'

      run {
        metadata = USCore::PractitionerGroup::metadata

        profile_definitions = [
          {
            profile: metadata.profile_url,
            must_support_info: metadata.must_supports.deep_dup,
            binding_info: metadata.bindings.deep_dup
          }
        ]

        assert output_conforms_to_profile?('Practitioner', profile_definitions), 'Resources do not conform to profile.'
      }
    end

    test do
      title 'Provenance resources returned conform to the US Core Provenance Profile'
      description <<~DESCRIPTION
        This test verifies that the resources returned from bulk data export conform to the US Core profiles. This includes checking for missing data elements and value set verification.
      DESCRIPTION
      # link 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-provenance'

      run {
        metadata = USCore::ProvenanceGroup::metadata

        profile_definitions = [
          {
            profile: metadata.profile_url,
            must_support_info: metadata.must_supports.deep_dup,
            binding_info: metadata.bindings.deep_dup
          }
        ]

        assert output_conforms_to_profile?('Provenance', profile_definitions), 'Resources do not conform to profile.'
      }
    end

    test do
      title 'Location resources returned conform to the US Core Location Profile'
      description <<~DESCRIPTION
        This test verifies that the resources returned from bulk data export conform to the US Core profiles. This includes checking for missing data elements and value set verification.
      DESCRIPTION
      # link 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-location'

      run {
        #TODO: Should there be a US Core test? Can't seem to find the metadata
      }
    end

    test do
      title 'Medication resources returned conform to the US Core Medication Profile'
      description <<~DESCRIPTION
        This test verifies that the resources returned from bulk data export conform to the US Core profiles. This includes checking for missing data elements and value set verification.
      DESCRIPTION
      # link 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-medication'

      run {
        #TODO: Should there be a US Core test? Is this just MedicationRequest
      }
    end
  end
end
