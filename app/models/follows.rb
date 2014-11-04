class Follows
  attr_accessor :follower, :followed, :created_at, :rel

  def initialize(follower, followed)
    @follower = follower
    @followed = followed
    @created_at = nil
    @rel = nil
  end

  def create
    follow = $neo.create_relationship(:follows, follower.node, followed.node)
    $neo.set_relationship_properties(follow, { :created_at => Time.now })
    self.rel = follow
    self
  end
  class << self
    def get_existing(follower, following)
      query =<<-CYPHER
        MATCH (u:User {account_id: {account_id}})-[r:follows]->(f:User {account_id: {following_id}})
        RETURN r
      CYPHER

      data = $neo.execute_query(query, {account_id: follower.account_id, following_id: following.account_id})
      return nil if data["data"].first.nil?

      follows = self.new(follower, following)
      follows.rel = data["data"].first.try(:first)

      follows
    end

    def remove(follower, following)
      query =<<-CYPHER
        MATCH (u:User {account_id: {account_id}})-[r:follows]->(f:User {account_id: {following_id}})
        DELETE r
      CYPHER

      $neo.execute_query(query, {account_id: follower.account_id, following_id: following.account_id})
      nil
    end

    def count
      query =<<-CYPHER
          MATCH ()-[r:follows]->()
          RETURN count(r)
      CYPHER

      data = $neo.execute_query(query)
      data["data"].first.try(:first)
    end
  end
end