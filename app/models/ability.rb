class Ability
  include CanCan::Ability

  def initialize(user, member = nil, economy = nil)
    user   ||= User.new
    member ||= user.memberships.new

    alias_action :view, :create, :read, :update, :destroy, to: :crud

    can    :read,              Item
    can    :index,             Item
    can    :read,              Wish
    cannot :create,            Item

    if user.persisted?
      can :create, Economy
      can :crud,                 user.economies       { |i| i.user == user }
      can :crud, user
    end

    if member.persisted? # logged in an economy
      can    :create,            Item
      can    :crud,              member.items         { |i| i.member == member }
      can    :pause,             member.items         { |i| i.active? }
      cannot :pause,             Item.paused          { true }
      can    :activate,          member.items.paused  { true }
      cannot :activate,          Item.active          { |i| i.active? }
      
      can    :create,            Wish
      can    :crud,              member.wishes        { |i| i.member == member }
      can    :pause,             member.wishes        { |i| i.active? }
      cannot :pause,             Wish.paused          { true }
      can    :activate,          member.wishes.paused { true }
      cannot :activate,          Wish.active          { |i| i.active? }
      can    :fulfill,           Wish
      can    :create_wish_offer, Wish
      
      can    :show,              Member
      can    :crud,              member
      can    :crud,              user      
    end

    if member.persisted? and member.approved? 
      can    :purchase, Item.active                  { |i| i.member != member }
      cannot :purchase, member.items                 { true }
      can    :fulfill,  Wish.active.not_mine(member) { |w| w.member != member }
      cannot :fulfill,  member.wishes                { |w| w.member == member }
      can    :crud,     Conversation
      can    :crud,     Message
      can    :create,   Comment
      can    :view,     Comment
      can    :direct_transfer, Member.all              { |u| u != member }
      can    :transfer, Member.all { |u| u != member }
    end

    if economy
      if user.has_role? :manager, economy
        can :create, User
        can :crud,   economy.users { |u| u.manager_id = user.id }
      end
      if user.has_role? :admin
        can :create, User
        can :crud,   economy.users { true }
      end
      cannot :index, User
    end

    if user.has_role? :admin
      can :crud, User
      can :crud, Transaction
      can :crud, Member
      can :crud, Economy
    end

  end
end
