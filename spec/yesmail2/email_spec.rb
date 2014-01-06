module Yesmail2
  describe Email do
    describe '.send' do
      let(:template_id) { 'foo' }
      let(:subscriber) do
        { id: 'test@example.com', email: 'test@example.com' }
      end

      it 'invokes the correct shit' do
        body = { content: [template_id], recipients: [subscriber] }
        WebMock
          .stub_request(:post, 'https://api.yesmail.com/v2/emails/send')
          .with(body: body.to_json)
          .to_return(status: 200, body: '{}')

        Email.send([template_id], [subscriber])
      end
    end
  end
end
