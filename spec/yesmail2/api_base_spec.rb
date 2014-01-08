module Yesmail2
  describe ApiBase do
    describe '.http_method' do
      let(:url) { 'https://api.com/foo.json' }
      let(:api_user) { 'pat' }
      let(:api_key) { 'deadbeef' }

      before do
        Yesmail2.config.api_user = api_user
        Yesmail2.config.api_key = api_key
      end

      it 'sets the header "Api-User" and "Api-Key"' do
        headers = {
          'Api-User' => api_user,
          'Api-Key' => api_key,
          'Accept' => '*/*; q=0.5, application/xml',
          'Accept-Encoding' => 'gzip, deflate',
          'User-Agent' => 'Ruby'
        }
        WebMock.stub_request(:get, url)
          .with(headers: headers)
          .to_return(status: 200, body: '{}')

        ApiBase.http_method(:get, url)
      end
    end
  end
end
