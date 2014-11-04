class Includes
  attr_accessor :outfit, :image, :created_at, :rel

  def initialize(outfit, image)
    @outfit = outfit
    @image = image
    @created_at = nil
    @rel = nil
  end

  def create
    self.rel = $neo.create_relationship(:includes, outfit.node, image.node)
    $neo.set_relationship_properties(self.rel, { :created_at => Time.now })

    self
  end

  def self.get_existing(outfit, image)
    query =<<-CYPHER
      MATCH (o:Outfit {outfit_id: {outfit_id}})-[r:includes]->(i:Image {image_id: {image_id}})
      RETURN r
    CYPHER

    data = $neo.execute_query(query, {outfit_id: outfit.outfit_id, image_id: image.image_id})
    return nil if data["data"].first.nil?

    includes = self.new(outfit, image)
    includes.rel = data["data"].first.try(:first)

    includes
  end

  def self.count
    query =<<-CYPHER
        MATCH ()-[r:includes]->()
        RETURN count(r)
    CYPHER

    data = $neo.execute_query(query)
    data["data"].first.try(:first)
  end
end