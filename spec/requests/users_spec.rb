require 'swagger_helper'

describe 'User API', type: :request do
  let(:current_token) { Token.create }
  let(:current_user) { User.find_or_create_by(name: 'test', email: 'test@test.com', token: current_token)}
  let(:Authorization) { "Bearer #{current_user.token.value}"}

  path '/users' do
    post 'Create a new user' do
      consumes 'application/json'
      tags 'Users'
      description 'Create a user.'
      
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, example: 'Liam'},
          email: {type: :string, example: 'liam@enumedate.com'}
        },
        required: %w[name, email]
      }
      parameter name: 'Authorization', :in => :header, :type => :string

      response '200', 'success' do
        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        let(:user) { { name: 'liam1', email: 'liam1@enumedate.com'} }

        context 'new registered user' do
          before do
            allow(Token).to receive(:from_firebase_jwt)
              .with('FIREBASEJWT')
              .and_return(Token.new(firebase_data: { 'user_id' => '4242',
                                                    'firebase' => { 'identities' => {
                                                      'email' => ['liam1@enumedate.com'],
                                                      'phone' => ['+81901212121212']
                                                    } } }))
          end

          let(:Authorization) { "Bearer FIREBASEJWT"}

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['id']).to be_truthy
            expect(data['email']).to eq('liam1@enumedate.com')
            expect(data['registered_user']).to be_truthy
            expect(data['token']['id']).to be_truthy
            expect(data['token']['value']).to be_truthy
          end
        end

        context 'new anon user' do
          before do
            allow(Token).to receive(:from_firebase_jwt)
              .with('FIREBASEJWT')
              .and_return(Token.new(firebase_data: { 'user_id' => '0404' }))
          end

          let(:Authorization) { "Bearer FIREBASEJWT"}

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['id']).to be_truthy
            expect(data['email']).to be_nil
            expect(data['registered_user']).to be_falsy
            expect(data['token']['id']).to be_truthy
            expect(data['token']['value']).to be_truthy
          end
        end

      end
      response '400', 'Incorrect email' do
        let(:user) { { name: 'liam1', email: 'jlb' } }
        run_test!
      end
    end
  end

  path '/users/{id}' do
    get 'Get User Info' do
      consumes 'application/json'
      tags 'Users'
      description "Get User's info."
      parameter name: :id, in: :path, type: :string
      parameter name: 'Authorization', :in => :header, :type => :string

      response '200', 'success' do
        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        let(:id) { current_user.id }
        run_test!
      end

      response '403', 'Incorrect user id provided' do
        let(:id) { 42 }
        run_test!
      end

      response '401', 'Invalid Token' do
        let(:id) { current_user.id }
        let(:Authorization) { 'Bearer XXX' }
        run_test!
      end
    end
  end

  path '/users/{id}' do
    put 'Update User info' do
      consumes 'application/json'
      tags 'User'
      description "Update a users info."

      parameter name: :id, in: :path, type: :string
      parameter name: 'Authorization', :in => :header, :type => :string
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, example: 'Liam'},
          email: {type: :string, example: 'liam@enumedate.com'}
        }
      }

      response '200', 'success' do
        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        let(:id) { current_user.id }
        let(:user) { { name: 'liam b', email: 'product@enumedate.com' } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq('liam b')
          expect(data['email']).to eq('product@enumedate.com')
        end
      end

      response '403', 'Access Denied' do
        context 'Incorrect user id provided' do
          let(:id) { 23 }
          let(:user) { { name: 'liam b', email: 'product@enumedate.com' } }

          run_test!
        end
      end

      response '401', 'Invalid Token' do
        let(:id) { current_user.id }
        let(:Authorization) { 'Bearer XXX' }
        let(:user) { { name: 'liam b', email: 'product@enumedate.com' } }

        run_test!
      end
    end
  end

  path '/users/{id}' do
    delete 'Delete a User' do
      consumes 'application/json'
      tags 'Users'
      description "Delete a user."

      parameter name: :id, in: :path, type: :string
      parameter name: 'Authorization', :in => :header, :type => :string

      response '200', 'success' do
        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        let(:id) { current_user.id }

        run_test! do |_response|
          expect { User.find(id) }.to raise_exception(ActiveRecord::RecordNotFound)
        end
      end

      response '401', 'Invalid Token' do
        after do |example|
          example.metadata[:response][:content] ||= { 'application/json': { 'examples': {} } }
          example.metadata[:response][:content][:'application/json'][:examples][self.class.description] =
            { value: JSON.parse(response.body, symbolize_names: true) }
        end
        context 'invalid bearer provided' do
          let(:id) { current_user.id }
          let(:Authorization) { 'Bearer XXX' }
          run_test!
        end
      end
    end
  end
end