require 'spec_helper'

describe SessionsController do
    describe "POST #create" do

        before(:each) do
            @user = FactoryGirl.create :user
        end

        context "when the credentials are correct" do

            before(:each) do
                credentials = { email: @user.email, password: "testpass" }
                post :create, params: { session: credentials }
            end

            it "returns the user record corresponding to the given credentials" do
                @user.reload
                expect(json_response[:auth_token]).to eql @user.auth_token
                expect(json_response[:id]).to eql @user.id
                expect(json_response[:email]).to eql @user.email
                expect(json_response[:first_name]).to eql @user.first_name
                expect(json_response[:last_name]).to eql @user.last_name
                expect(json_response[:image]).to eql @user.image.url
                expect(json_response[:bio]).to eql @user.bio
                expect(json_response[:url]).to eql @user.url
            end

            it { should respond_with 200 }
        end

        context "when the credentials are incorrect" do

            before(:each) do
                credentials = { email: @user.email, password: "invalidpassword" }
                post :create, params: { session: credentials }
            end

            it "returns a json with an error" do
                expect(json_response[:errors]).to eql "Invalid email or password"
            end

            it { should respond_with 422 }
        end
    end
    describe "DELETE #destroy" do

        before(:each) do
            @user = FactoryGirl.create :user
            sign_in @user
            delete :destroy, params: { id: @user.auth_token }
        end

        it { should respond_with 204 }

    end
end
