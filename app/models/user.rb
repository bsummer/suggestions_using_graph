class User
  attr_accessor :account_id, :first_name, :last_name, :node

  def initialize(args)
    @first_name = args[:first_name]
    @last_name = args[:last_name]
    @account_id = args[:account_id]
    @node = {}
  end

  def follows(followed)
    follow = Follows.get_existing(self,followed)
    if (follow.nil?)
      follow = Follows.new(self, followed)
      follow.create
    end

    follow
  end

  def unfollows(followed)
    Follows.remove(self,followed)
  end

  def posts(outfit)
    post = Posts.get_existing(self,outfit)
    if (post.nil?)
      post = Posts.new(self, outfit)
      post.create
    end

    post
  end

  def loves(outfit)
    love = Loves.get_existing(self,outfit)
    if (love.nil?)
      love = Loves.new(self, outfit)
      love.create
    end

    love
  end

  def following
    query =<<-CYPHER
      MATCH (u:User {account_id: {account_id}})-[r:follows]->(f)
      RETURN f
      ORDER BY r.created_at DESC
    CYPHER

    User.convert_from_nodes $neo.execute_query(query, {account_id: account_id})
  end

  def followers
    query =<<-CYPHER
      MATCH (u:User {account_id: {account_id}})<-[:follows]-(f)
      RETURN f
    CYPHER

    User.convert_from_nodes $neo.execute_query(query, {account_id: account_id})
  end

  def recommended
    query =<<-CYPHER
     MATCH (u:User {account_id: {account_id}})-[:follows]->(f1)-[:follows]->(f2)<-[:follows]-(n)
     WHERE NOT (u)-[:follows]->(f2)
     RETURN f2, count(n)
     ORDER BY count(n) DESC
     LIMIT 6
    CYPHER

    User.convert_from_nodes $neo.execute_query(query, {account_id: account_id})
  end

  def loved
    query =<<-CYPHER
      MATCH (u:User {account_id: {account_id}})-[:loves]->(f)
      RETURN f
    CYPHER

    Outfit.convert_from_nodes $neo.execute_query(query, {account_id: account_id})
  end

  def posted
    query =<<-CYPHER
      MATCH (u:User {account_id: {account_id}})-[:posts]->(f)
      RETURN f
    CYPHER

    Outfit.convert_from_nodes $neo.execute_query(query, {account_id: account_id})
  end

  def following?(following_id)
    !Follows.get_existing(self,User.find(following_id)).nil?
  end

  def get_last_outfit_image
    query =<<-CYPHER
      MATCH (u:User {account_id: {account_id}})-[:posts]->(o:Outfit)-[:includes]->(i:Image)
      RETURN i
      ORDER BY o.created_at DESC
      LIMIT 1
    CYPHER

    data = $neo.execute_query(query, {account_id: account_id})
    Image.convert_from_node data["data"].first.try(:first)
  end

  def get_last_outfit_image_url
    query =<<-CYPHER
      MATCH (u:User {account_id: {account_id}})-[:posts]->(o:Outfit)-[:includes]->(i:Image)
      RETURN i.url
      ORDER BY o.created_at DESC
      LIMIT 1
    CYPHER

    data = $neo.execute_query(query, {account_id: account_id})
    data["data"].first.try(:first)
  end

  def to_hash
    {:first_name => first_name, :last_name => last_name, :account_id => account_id}
  end

  class << self
    def all(limit=100)
      query =<<-CYPHER
        MATCH (u:User)
        RETURN u
        LIMIT {limit}
      CYPHER

      convert_from_nodes $neo.execute_query(query, {limit: limit})
    end

    def count
      query =<<-CYPHER
        MATCH (u:User)
        RETURN count(u)
      CYPHER

      data = $neo.execute_query(query)
      data["data"].first.try(:first)
    end

    def create(attrs)
      u = User.new(attrs)
      u.node = $neo.create_node(attrs)
      $neo.add_label(u.node, "User")
      u
    end

    def find(account_id)
      query =<<-CYPHER
        MATCH (u:User {account_id: {account_id}})
        RETURN u
      CYPHER

      nodes = $neo.execute_query(query, {account_id: account_id})

      convert_from_node nodes["data"].try(:first).try(:first)
    end

    def find_or_create(attrs)
      User.find(attrs[:account_id]) || User.create(attrs)
    end

    def convert_from_nodes(nodes)
      (nodes["data"] || []).map do |node|
        convert_from_node(node.first)
      end
    end

    def convert_from_node(node)
      if node
        return_node = self.new({})
        return_node.first_name = node["data"]["first_name"]
        return_node.last_name = node["data"]["last_name"]
        return_node.account_id = node["data"]["account_id"]
        return_node.node = node
      end

      return_node || nil
    end
  end
end