class UserStateMachine
  include Statesman::Machine

  state :enabled, initial: true
  state :disabled

  transition from: :enabled, to: [:disabled]
  transition from: :disabled, to: [:enabled]
end
