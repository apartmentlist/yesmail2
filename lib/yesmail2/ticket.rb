module Yesmail2
  class Ticket < ApiBase
    def self.api_path
      'tickets'
    end

    def self.status(id)
      # GET tickets/{id}
      get(full_path(id), :params => {})
    end
  end
end


