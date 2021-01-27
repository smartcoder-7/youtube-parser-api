require "rails_helper"

RSpec.describe Api::V1::UploadsController, :type => :controller do
  describe "uploads files" do
    let(:file1) { fixture_file_upload(file_fixture('file1.csv')) }
    let(:file2) { fixture_file_upload(file_fixture('file2.csv')) }

    let(:parsed_response) { JSON.parse(response.body) }

    it "uploads files responds with discrepancy emails json array" do
      post :upload, :params => { :File => [file1, file2], concern: "Any Concern" }
      expect(response.content_type).to eq "application/json; charset=utf-8"
      expect(parsed_response["emails"]).should_not be_nil
    end
  end
end
