require "rails_helper"

RSpec.describe Invitation do
  describe "callbacks" do
    describe "after_save" do
      context "with valid data" do
        it "invites the user" do
          new_user = create_user
          invitation = build_invitation_with_user(new_user)

          invitation.save

          expect(new_user).to be_invited
        end
      end

      context "with invalid data" do
        it "does not save the invitation" do
          invitation = build_invalid_invitation

          invitation.save

          expect(invitation).not_to be_valid
          expect(invitation).to be_new_record
        end

        it "does not mark the user as invited" do
          new_user = create_user
          invitation = build_invalid_invitation_with_user(new_user)

          invitation.save

          expect(new_user).not_to be_invited
        end
      end
    end
  end

  describe "#event_log_statement" do
    context "when the record is saved" do
      it "include the name of the team" do
        invitation = build_invitation

        invitation.save
        log_statement = invitation.event_log_statement

        expect(log_statement).to include("A fine team")
      end

      it "include the email of the invitee" do
        invitation = build_invitation

        invitation.save
        log_statement = invitation.event_log_statement

        expect(log_statement).to include("rookie@example.com")
      end
    end

    context "when the record is not saved but valid" do
      it "includes the name of the team" do
        invitation = build_invitation

        log_statement = invitation.event_log_statement

        expect(log_statement).to include("A fine team")
      end

      it "includes the email of the invitee" do
        invitation = build_invitation

        log_statement = invitation.event_log_statement

        expect(log_statement).to include("rookie@example.com")
      end

      it "includes the word 'PENDING'" do
        invitation = build_invitation

        log_statement = invitation.event_log_statement

        expect(log_statement).to include("PENDING")
      end
    end

    context "when the record is not saved and not valid" do
      it "includes INVALID" do
        invitation = build_invalid_invitation

        log_statement = invitation.event_log_statement

        expect(log_statement).to include("INVALID")
      end
    end
  end

  def create_user
    User.create!(email: "rookie@example.com")
  end

  def create_team
    team_owner = User.create!
    team = Team.create!(name: "A fine team")
    team.update!(owner: team_owner)
    team_owner.update!(team: team)
    team
  end

  def build_invitation
    user = create_user
    team = create_team
    Invitation.new(team: team, user: user)
  end

  def build_invitation_with_user(user)
    team = create_team
    Invitation.new(team: team, user: user)
  end

  def build_invalid_invitation
    user = create_user
    Invitation.new(team: nil, user: user)
  end

  def build_invalid_invitation_with_user(user)
    Invitation.new(team: nil, user: user)
  end
end
