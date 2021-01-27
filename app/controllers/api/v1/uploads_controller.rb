module Api
  module V1
    class UploadsController < ApplicationController
      require 'csv'

      def upload
        raise "Missing 'file1.csv'" if params[:File][0].nil?
        raise "Missing 'file2.csv'" if params[:File][1].nil?
        # Rails.logger.debug params[:File]

        file1 = CSV.read(params[:File][0], headers: true)
        file2 = CSV.read(params[:File][1], headers: true)

        @file1 = file1
        @file2 = file2
        @concern = params[:concern]

        @emails_with_discrepancies = yt_data_checker(@file1, @file2, @concern)

        render json: {emails: @emails_with_discrepancies}

      end

      private

      	#checks for concern, directs correct files.
        def yt_data_checker(file1, file2, concern)

          if concern == "channel_ownership"
            sanitize_channels(file1, file2)
            calculate_differences(@file_1_yt_channels, @file_2_yt_channels)
            print_emails(@total_difference)
          elsif concern == "subscriber_count"
            sanitize_subscriber_count(file1, file2)
            calculate_differences(@file_1_subscriber_count, @file_2_subscriber_count)
            print_emails(@total_difference)
          else
            sanitize_channels(file1, file2)
            sanitize_subscriber_count(file1, file2)
            calculate_differences(@file_1_yt_channels, @file_2_yt_channels)
            calculate_differences(@file_1_subscriber_count, @file_2_subscriber_count)
            print_emails(@total_difference)
          end
        end


        #Normalizes channels
        def sanitize_channels(file1, file2)
          @file_1_yt_channels = {}
          @file_2_yt_channels = {}

          file1.each do |row|
            @file_1_yt_channels[row[0]] = row[1].split('/').last #.gsub(/^UC/, "") -> Insert if UC is error in input 
          end

          file2.each do |row|
            @file_2_yt_channels[row[0]] = row[1].split('/').last #.gsub(/^UC/, "") -> Insert if UC is error in input
          end
        end


        #Normalizes subscriber count
        def sanitize_subscriber_count(file1, file2)
          @file_1_subscriber_count = {}
          @file_2_subscriber_count = {}

          file1.each do |row|
            @file_1_subscriber_count[row[0]] = row[2].gsub(/\W/, "").to_s
          end

          file2.each do |row|
            @file_2_subscriber_count[row[0]] = row[2].gsub(/\W/, "").to_s
          end
        end


        #Calculates between suppled channel_ownership, subscribe_count or both.
        def calculate_differences(data_set1, data_set2)
          @differences ||= []

          @differences = @differences +  (data_set1.to_a - data_set2.to_a)

          @total_difference = @differences
        end


        #Iterates through differneces, collects emails and prints them out.
        def print_emails(differences)

          emails = []

          differences.each do |difference|
            emails << difference[0]
          end

          # puts "-------Emails With Discrepancies------"
          # puts emails.uniq
          # puts "--------------------------------------"
          emails.uniq
        end

        def upload_params
          params.permit(:File)
        end
    end
  end
end
