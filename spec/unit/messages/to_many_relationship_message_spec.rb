require 'spec_helper'
require 'messages/to_many_relationship_message'

module VCAP::CloudController
  RSpec.describe ToManyRelationshipMessage do
    describe '.create_from_http_request' do
      let(:body) {
        {
          data: [
            { 'guid' => 'some-guid' },
            { 'guid' => 'some-guid-2' }
          ]
        }
      }

      it 'returns the correct ToManyRelationshipMessage' do
        message = ToManyRelationshipMessage.create_from_http_request(body)

        expect(message).to be_a(ToManyRelationshipMessage)
        expect(message.guids).to eq(['some-guid', 'some-guid-2'])
      end

      it 'converts requested keys to symbols' do
        message = ToManyRelationshipMessage.create_from_http_request(body)

        expect(message.requested?(:data)).to be_truthy
      end
    end

    describe 'validations' do
      context 'when there are no guids in the data' do
        let(:params) do
          {
            data: []
          }
        end

        it 'returns an error' do
          message = ToManyRelationshipMessage.new(params)

          expect(message).to_not be_valid
          expect(message.errors[:data]).to include("can't be blank")
        end
      end

      context 'when data is not an array' do
        let(:params) do
          {
            data: 'boo'
          }
        end

        it 'returns an error' do
          message = ToManyRelationshipMessage.new(params)

          expect(message).to_not be_valid
          expect(message.errors[:data]).to include('must be an array')
        end
      end

      context 'when unexpected keys are requested' do
        let(:params) {
          {
            unexpected: 'an-unexpected-value',
          }
        }

        it 'is not valid' do
          message = ToManyRelationshipMessage.new(params)

          expect(message).to_not be_valid
          expect(message.errors[:base]).to include("Unknown field(s): 'unexpected'")
        end

        context 'when the guid is not a string' do
          let(:params) do
            {
              data: [
                { guid: 32.77 }
              ]
            }
          end

          it 'is not valid' do
            message = ToManyRelationshipMessage.new(params)

            expect(message).not_to be_valid
            expect(message.errors[:data]).to include('32.77 not a string')
          end
        end
      end
    end
  end
end
