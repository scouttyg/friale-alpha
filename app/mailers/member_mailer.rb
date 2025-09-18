class MemberMailer < ApplicationMailer
  def invitation_email(member)
    @member = member
    @account = member.source
    @creator = member.creator
    @invitation_url = accept_invitation_url(token: member.invite_token)

    mail(
      to: member.invite_email,
      subject: "You've been invited to join #{@account.name}",
      from: ENV['DEFAULT_FROM_EMAIL'] || "noreply@example.com"
    )
  end
end
