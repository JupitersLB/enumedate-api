require 'swagger_helper'

RSpec.describe "Event API", type: :request do
  let(:current_token) { Token.create }
  let(:current_user) { User.find_or_create_by(name: 'test', email: 'test@test.com', token: current_token)}
  let(:current_event) { create :event, title: 'Got Married', start_date: DateTime.new(2020, 07, 20, 12, 30), user: current_user}
  let(:Authorization) { "Bearer #{current_user.token.value}"}

  RSpec.shared_examples 'successful post request' do
    run_test! do |response|
      data = JSON.parse(response.body)
      expect(data['id']).to be_truthy
      expect(data['title']).to eq(current_event.title)
      expect(data['start_date']).to eq(current_event.start_date)
      expect(data['unit']).to eq('days') # default unit
    end
  end

  path '/events' do
    post 'Create a new event' do
      consumes 'application/json'
      tags 'Events'
      description 'Creates an Event'
      parameter name: 'Authorization', in: :header, type: :string
      parameter name: :event, in: :body, schema: {
        type: :object,
        properties: {
          start_date: { type: :string, example: '2020-07-20 12:30:00',
                        description: 'Start date follows iso8601 format' },
          unit: { type: :string, example: 'days' },
          title: { type: :string, example: 'title for an event'},
        }
      }

      response '200', 'success' do
        after do |example|
          example.metadata[:response][:content] ||= { 'application/json': { 'examples': {} } }
          example.metadata[:response][:content][:'application/json'][:examples][self.class.description] =
            { value: JSON.parse(response.body, symbolize_names: true) }
        end

        let(:event) do
          {
            title: 'Wedding',
            start_date: '2020-07-20T12:31:00.000Z',
            unit: 'days',
          }
        end

        context 'with user token' do
          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['id']).to be_truthy
            expect(data['title']).to eq(event[:title])
            expect(data['start_date']).to eq(event[:start_date])
            expect(data['unit']).to eq('days') # default unit
          end
        end
      end

      response '400', 'Bad Request' do
        context 'invalid start_date' do
          let(:event) do
            {
              title: 'cropzone 1',
              start_date: 'Some Date',
            }
          end

          run_test!
        end
      end

      response '401', 'Invalid Token' do
        context 'Invalid token' do
          let(:Authorization) { 'Bearer XXX' }
          let(:event) do
            {
              title: 'Wedding',
              start_date: '2020-07-20 12:30:00',
              unit: 'days',
            }
          end

          run_test!
        end
      end
    end
  end

  path '/events' do
    get 'List of events' do
      consumes 'application/json'
      tags 'Events'
      description 'Gets a list of events'
      parameter name: 'Authorization', in: :header, type: :string

      response '200', 'success' do
        after do |example|
          example.metadata[:response][:content] ||= { 'application/json': { 'examples': {} } }
          example.metadata[:response][:content][:'application/json'][:examples][self.class.description] =
            { value: JSON.parse(response.body, symbolize_names: true) }
        end

        let!(:event_1) { create(:event, user: current_user) }
        let!(:event_2) { create(:event, user: current_user) }
        let!(:event_3) { create(:event, user: current_user) }
        
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.count).to eq(3)
          expect(data[1]['id']).to eq(event_2.id)
        end
      end
    end
  end
end
