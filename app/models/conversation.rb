class Conversation < ApplicationRecord
  belongs_to :author, class_name: 'User'
  belongs_to :recipient, class_name: 'User'

  validates :author_id, presence: true
  validates_uniqueness_of :author_id, scope: :recipient_id

  has_many :messages, -> { order(created_at: :asc) }, dependent: :destroy
  has_many :timely_responses, dependent: :destroy
  
  scope :participating, -> (user) do
    includes(:messages).where("(conversations.author_id = ? OR conversations.recipient_id = ?)", user.id, user.id)
  end

  scope :sent_by, -> (user) do
    includes(:messages).where("conversations.author_id = ?", user.id)
  end

  scope :received_by, -> (user) do
    includes(:messages).where("conversations.recipient_id = ?", user.id)
  end

  scope :between, -> (sender_id, recipient_id) do
    where(author_id: sender_id, recipient_id: recipient_id).or(where(author_id: recipient_id, recipient_id: sender_id)).limit(1)
  end

  def with(current_user)
    author == current_user ? recipient : author
  end

  def participates?(user)
    author == user || recipient == user
  end

end
