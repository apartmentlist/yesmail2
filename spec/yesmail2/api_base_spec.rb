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

      it 'returns a Hashie::Mash representing the JSON response' do
        WebMock.stub_request(:get, url)
          .to_return(status: 200, body: '{"foo":"bar","biz":3}')

        result = ApiBase.http_method(:get, url)
        result.should be_a(Hashie::Mash)
        result.foo.should eq('bar')
        result.biz.should eq(3)
      end

      context 'when the response code is 202' do
        it 'returns a Hashie::Mash representing the JSON response' do
          WebMock.stub_request(:get, url)
            .to_return(status: 202, body: '{"foo":"bar","biz":3}')

          result = ApiBase.http_method(:get, url)
          result.should be_a(Hashie::Mash)
          result.foo.should eq('bar')
          result.biz.should eq(3)
        end
      end

      context 'when the response body is empty' do
        before do
          WebMock.stub_request(:get, url)
            .to_return(status: 200, body: '')
        end

        it 'returns a Hashie for a blank response' do
          ApiBase.http_method(:get, url).should be_a(Hashie::Mash)
        end
      end
    end
  end
end
