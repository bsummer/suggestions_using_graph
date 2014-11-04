class Posts
  attr_accessor :user, :outfit, :created_at, :rel

  def initialize(user, outfit)
    @user = user
    @outfit = outfit
    @created_at = nil
    @rel = nil
  end

  def create
    self.rel = $neo.create_relationship(:posts, user.node, outfit.node)
    $neo.set_relationship_properties(self.rel, { :created_at => Time.now })

    self
  end

  def self.get_existing(user, outfit)
    query =<<-CYPHER
      MATCH (u:User {account_id: {account_id}})-[r:posts]->(o:Outfit {outfit_id: {outfit_id}})
      RETURN r
    CYPHER

    data = $neo.execute_query(query, {account_id: user.account_id, outfit_id: outfit.outfit_id})
    return nil if data["data"].first.nil?

    posts = self.new(user, outfit)
    posts.rel = data["data"].first.try(:first)

    posts
  end

  def self.count
    query =<<-CYPHER
        MATCH ()-[r:posts]->()
        RETURN count(r)
    CYPHER

    data = $neo.execute_query(query)
    data["data"].first.try(:first)
  end
end