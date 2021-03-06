describe WPScan::Finders::Users::OembedApi do
  subject(:finder) { described_class.new(target) }
  let(:target)     { WPScan::Target.new(url) }
  let(:url)        { 'http://wp.lab/' }
  let(:fixtures)   { File.join(FINDERS_FIXTURES, 'users', 'oembed_api') }

  describe '#aggressive' do
    before do
      allow(target).to receive(:sub_dir).and_return(false)
      stub_request(:get, finder.api_url).to_return(body: body)
    end

    context 'when not a JSON response' do
      let(:body) { '' }

      its(:aggressive) { should eql([]) }
    end

    context 'when a JSON response' do
      context 'when 404' do
        let(:body) { File.read(File.join(fixtures, '404.json')) }

        its(:aggressive) { should eql([]) }
      end

      context 'when 200' do
        context 'when author_url present' do
          let(:body) { File.read(File.join(fixtures, '200_author_url.json')) }

          it 'returns the expected array of users' do
            users = finder.aggressive

            expect(users.size).to eql 1

            user = users.first

            expect(user.username).to eql 'admin'
            expect(user.confidence).to eql 90
            expect(user.found_by).to eql 'Oembed API - Author URL (Aggressive Detection)'
            expect(user.interesting_entries).to eql ['http://wp.lab/wp-json/oembed/1.0/embed?url=http://wp.lab/&format=json']
          end
        end

        context 'when author_url not present but author_name' do
          let(:body) { File.read(File.join(fixtures, '200_author_name.json')) }

          it 'returns the expected array of users' do
            users = finder.aggressive

            expect(users.size).to eql 1

            user = users.first

            expect(user.username).to eql 'admin sa'
            expect(user.confidence).to eql 70
            expect(user.found_by).to eql 'Oembed API - Author Name (Aggressive Detection)'
            expect(user.interesting_entries).to eql ['http://wp.lab/wp-json/oembed/1.0/embed?url=http://wp.lab/&format=json']
          end
        end
      end
    end
  end
end
