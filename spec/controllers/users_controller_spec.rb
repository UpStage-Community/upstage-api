require 'spec_helper'

describe UsersController do

    describe "GET #show" do
        before(:each) do
            @user = FactoryGirl.create :user
            get :show, params: { id: @user.id }
        end

        it "returns the information about a reporter on a hash" do
            user_response = json_response
            expect(user_response[:email]).to eql @user.email
        end

        it { should respond_with 200 }

    end

    describe "POST #create" do
        context "when is successfully created" do
            before(:each) do
                @user_attributes = FactoryGirl.attributes_for :user
                post :create, params: { user: @user_attributes }
            end

            it "renders the json representation for the user just created" do
                user_response = json_response
                expect(user_response[:email]).to eql @user_attributes[:email]
            end

            it { should respond_with 201 }
        end

        context "when is not created" do
            before(:each) do
                @invalid_user_attributes = {
                    password: "testpass",
                    password_confirmation: "testpass"
                }
                post :create, params: { user: @invalid_user_attributes }
            end

            it "renders an errors json" do
                user_response = json_response
                expect(user_response).to have_key(:errors)
            end

            it "renders the json errors on why the user could not be created" do
                user_response = json_response
                expect(user_response[:errors][:email]).to include "can't be blank"
            end

            it { should respond_with 422 }
        end
    end

    describe "PUT/PATCH #update" do

        before(:each) do
            @user = FactoryGirl.create :user
        end

        context "when user not authenticated" do
            before(:each) do
                patch :update, params: { 
                    id: @user.id,
                    user: { email: "newmail@example.com" } 
                }
            end
            
            it "does not allow update without authentication" do
                expect(json_response[:errors]).to eql "Not authenticated"
            end

            it { should respond_with 401 }

        end

        context "when user authenticated" do
            before(:each) do
                api_authorization_header @user.auth_token
            end


            context "when is successfully updated" do
                before(:each) do
                patch :update, params: { id: @user.id,
                               user: { email: "newmail@example.com" } }
                end

                it "renders the json representation for the updated user" do
                    user_response = json_response
                    expect(user_response[:email]).to eql "newmail@example.com"
                end

                it { should respond_with 200 }
            end
            
            context "when user updates someone else" do
                before(:each) do
                    @other_user = FactoryGirl.create :user
                    patch :update, params: { id: @other_user.id,
                                    user: { email: "newmail@example.com" } }
                end

                it "renders an errors json" do
                    user_response = json_response
                    expect(user_response).to have_key(:errors)
                end

                it "renders a forbidden error" do
                    user_response = json_response
                    expect(user_response[:errors]).to eql "You do not have permission to perform this action"
                end

                it { should respond_with 403 }

            end

            context "when is not updated" do
                before(:each) do
                    patch :update, params: { 
                        id: @user.id,
                        user: { email: "bademail.com" } 
                    }
                end

                it "renders an errors json" do
                    user_response = json_response
                    expect(user_response).to have_key(:errors)
                end

                it "renders the json errors on why the user could not be created" do
                    user_response = json_response
                    expect(user_response[:errors][:email]).to include "is invalid"
                end

                it { should respond_with 422 }
            end
        end
    end

    describe "DELETE #destroy" do

        before(:each) do
            @user = FactoryGirl.create :user
        end
        before(:each) do
        end

        context "when user not authenticated" do
            before(:each) do
                delete :destroy, params: { id: @user.id }
            end
            
            it "does not allow delete without authentication" do
                expect(json_response[:errors]).to eql "Not authenticated"
            end

            it { should respond_with 401 }

        end

        context "when user is authenticated" do
            before(:each) do
                api_authorization_header @user.auth_token
            end

            context "when deleting another user" do
                before(:each) do
                    @other_user = FactoryGirl.create :user
                    delete :destroy, params: { id: @other_user.id }
                end
                
                it "renders an errors json" do
                    user_response = json_response
                    expect(user_response).to have_key(:errors)
                end

                it "renders a forbidden error" do
                    user_response = json_response
                    expect(user_response[:errors]).to eql "You do not have permission to perform this action"
                end

                it { should respond_with 403 }
            end

            context "when deleting self" do
                before(:each) do
                    delete :destroy, params: { id: @user.id }
                end

                it { should respond_with 204 }
            end


        end
        

    end
end
