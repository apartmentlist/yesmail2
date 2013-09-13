module Yesmail2
  class ReferenceData < ApiBase
    def self.api_path
      'reference-data'
    end

    def self.summary
      # GET reference-data
      get(full_path, {})
    end

    def self.dataset_summary(dataset_name)
      # GET reference-data/{dataset}
      get(full_path(dataset_name), :params => {})
    end

    def self.records(dataset_name, options = {})
      # GET reference-data/{dataset}/records
      get(full_path(dataset_name, 'records'), :params => options)
    end

    # WARN: this code is untested
    def self.record(dataset_name, record_id, options = {})
      options.merge!({dataset: dataset_name})

      #GET reference-data/{dataset}/records/{recordid}
      get(full_path(dataset_name, 'records', record_id), :params => options)
    end

    def self.view_schema(dataset_name)
      # GET reference-data/{dataset}?view=schema
      get(full_path(dataset_name), :params => {:view => 'schema'})
    end

    # You have to know the record_id before you can add a record.  If you don't,
    # use the upsert_records method.
    # WARN: this code is untested
    def self.upsert_record(dataset_name, record_id, attributes)

      #PUT reference-data/{dataset}/records/{recordid}
      r = put(full_path(dataset_name, 'records', record_id), attributes)
    end

    # @param dataset_name [String]
    # @param records [Array<Hash>] an array of records to be upserted
    #
    # Records should be in the form...
    #
    # {
    #     "primarycolumnname1": "value6",
    #     "primarycolumnname2": "value7",
    #     "primarycolumnname3": "value8",
    #     "columnname4": "value9",
    #     "columnname5": "value10",
    #     …additional column names for the dataset, and values for the specified record
    # },
    #
    def self.upsert_records(dataset_name, records)
      #POST reference-data/{dataset}/records/update
      r = post(full_path(dataset_name, 'records', 'update'), records.to_json, :content_type => :json, :accept => :json)
    end

    # WARN: this code is untested
    def self.delete_record(dataset_name, record_id)

      #DELETE /reference-data/{dataset}/records/{recordid}
      delete(full_path(dataset_name, 'records', record_id))
    end

  end
end


