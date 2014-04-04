require 'spec_helper'
require "email_spec"

describe 'misc forklift core' do  
  describe 'email' do
    include EmailSpec::Helpers
    include EmailSpec::Matchers

    it "can send mail with an email template" do
      plan = SpecPlan.new
      plan.do! {
        email_args = {
          :to      => "YOU@FAKE.com",
          :from    => "Forklift",
          :subject => "Forklift has moved your database",
        }
        email_variables = {
          :total_users_count => 10,
          :new_users_count => 5,
        }
        email_template = "#{File.dirname(__FILE__)}/../template/spec_email_template.erb"
        @email = plan.mailer.send_template(email_args, email_template, email_variables).first
      }
      
      @email.should deliver_to("YOU@FAKE.com")
      @email.should have_subject(/Forklift has moved your database/)
      @email.should have_body_text(/Your forklift email/) # base 
      @email.should have_body_text(/Total Users: 10/) # template
      @email.should have_body_text(/New Users: 5/) # template
    end

    it "can send mail with an attachment" do 
      pending("how to test email attachments?")
    end
  end

  describe 'pidfile' do
    it "can create a pidfile and will remove it when the plan is over" do
      plan = SpecPlan.new
      pid = "#{File.dirname(__FILE__)}/../pid/pidfile"
      expect(File.exists?(pid)).to eql false
      plan.do! {
        expect(File.exists?(pid)).to eql true
        expect(File.read(pid).to_i).to eql Process.pid
      }
      expect(File.exists?(pid)).to eql false
    end

    it "will not run with an existing pidfile" do 
      plan = SpecPlan.new
      plan.pid.store!
      expect { plan.do! }.to raise_error SystemExit
      plan.pid.delete!
    end 
  end

end