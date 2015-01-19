require 'spec_helper'

describe StatusesController, :type => :controller do
  subject { described_class }

  describe "#index" do
    it "lists all the statuses" do
      joe = users(:joe)
      jane = users(:jane)
      dave = users(:dave)
      api_key = joe.session_api_key

      status1 = Status.create!(lat: 'latitude0', long: 'longitude0', body: 'some text0', duration: '1200', user: joe)
      status2 = Status.create!(lat: 'latitude1', long: 'longitude1', body: 'some text1', duration: '1200', user: jane)
      status3 = Status.create!(lat: 'latitude2', long: 'longitude2', body: 'some text2', duration: '1200', user: dave)

      post :list, {}, { 'Authorization' => "Bearer #{api_key.access_token}" }, format: :json
      response.should be_success
      json_response = JSON.parse(response.body)
      json_response["statuses"].count.should == 3
    end

    it "fails to list all the statuses" do
      joe = users(:joe)
      jane = users(:jane)
      dave = users(:dave)

      status1 = Status.create!(lat: 'latitude0', long: 'longitude0', body: 'some text0', duration: '1200', user: joe)
      status2 = Status.create!(lat: 'latitude1', long: 'longitude1', body: 'some text1', duration: '1200', user: jane)
      status3 = Status.create!(lat: 'latitude2', long: 'longitude2', body: 'some text2', duration: '1200', user: dave)

      post :list, {}, { 'Authorization' => "Bearer invalid-token}" }, format: :json
      response.status.should == 401
    end
  end

  describe "#create" do
    it "fails to create a status if the user is not valid" do
      status = {
            status: {
              lat: '42.969624',
              long: '-85.664793',
              body: 'Going to Founders!',
              created_at: 'time',
              duration: 'secret',
              image_url: "http://something.com"
            }
      }


      post :create, status, { 'Authorization' => "Bearer invalid-token-id" }, format: :json
      response.status.should == 401

      # request.headers["X-LabCompass-Auth"] = "some-invalid-id"
    end


    it "creates a status if the user authenticates" do
      joe = users(:joe)
      data = {
            status: {
              "lat" => '42.969624',
              "long" => '-85.664793',
              "body" => 'Going to Founders!',
              "created_at" => 'time',
              "duration" => 'secret',
              "image_url" => "http://something.com"
            }
      }
      api_key = joe.session_api_key

      requestor_id = joe.id
      status = Status.create!(lat: "42.969624", long: "-85.664793", body: "Going to Founders", duration: "1200", user: joe)

      UserLookup.expects(:find_user_id_by_token).with(api_key.access_token).returns(requestor_id)
      StatusCreator.expects(:create).with(data[:status], requestor_id).returns(status)
      post :create, data, { 'Authorization' => "Bearer #{api_key.access_token}" }, format: :json
      response.should be_success
      response.body.should == {user_id: status.user_id, status_id: status.id}.to_json
    end
  end
end