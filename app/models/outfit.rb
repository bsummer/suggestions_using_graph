class Outfit
  attr_accessor :outfit_id, :created_at, :node

  def initialize(args)
    @created_at = args[:created_at]
    @outfit_id = args[:outfit_id]
    @node = {}
  end

  def includes(image)
    include = Includes.get_existing(self,image)
    if (include.nil?)
      include = Includes.new(self, image)
      include.create
    end

    include
  end

  def lovers
    query =<<-CYPHER
      MATCH (o:Outfit {outfit_id: {outfit_id}})<-[:loves]-(u)
      RETURN u
    CYPHER

    User.convert_from_nodes $neo.execute_query(query, {outfit_id: outfit_id})
  end

  def image
    query =<<-CYPHER
      MATCH (o:Outfit {outfit_id: {outfit_id}})-[:includes]->(i)
      RETURN i
      LIMIT 1
    CYPHER


    node = $neo.execute_query(query, {outfit_id: outfit_id})
    Image.convert_from_node node["data"].try(:first).try(:first)
  end

  class << self
    def all
      query =<<-CYPHER
        MATCH (o:Outfit)
        RETURN o
      CYPHER

      convert_from_nodes $neo.execute_query(query)
    end

    def count
      query =<<-CYPHER
        MATCH (o:Outfit)
        RETURN count(o)
      CYPHER

      data = $neo.execute_query(query)
      data["data"].first.try(:first)
    end

    def create(attrs)
      u = self.new(attrs)
      u.node = $neo.create_node(attrs)
      $neo.add_label(u.node, "Outfit")
      u
    end

    def find(outfit_id)
      query =<<-CYPHER
        MATCH (o:Outfit {outfit_id: {outfit_id}})
        RETURN o
      CYPHER

      nodes = $neo.execute_query(query, {outfit_id: outfit_id})

      convert_from_node nodes["data"].try(:first).try(:first)
    end

    def find_or_create(attrs)
      self.find(attrs[:outfit_id]) || self.create(attrs)
    end

    def convert_from_nodes(nodes)
      (nodes["data"] || []).map do |node|
        convert_from_node(node.first)
      end
    end

    def convert_from_node(node)
      if node
        return_node = self.new({})
        return_node.created_at = node["data"]["created_at"]
        return_node.outfit_id = node["data"]["outfit_id"]
        return_node.node = node
      end

      return_node || nil
    end
  end
end