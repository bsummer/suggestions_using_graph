class Image
  attr_accessor :image_id, :url, :width, :height, :node

  def initialize(args)
    @image_id = args[:image_id]
    @url = args[:url]
    @width = args[:width]
    @height = args[:height]
    @node = {}
  end

  class << self
    def all
      query =<<-CYPHER
        MATCH (i:Image)
        RETURN i
      CYPHER

      convert_from_nodes $neo.execute_query(query)
    end

    def count
      query =<<-CYPHER
        MATCH (i:Image)
        RETURN count(i)
      CYPHER

      data = $neo.execute_query(query)
      data["data"].first.try(:first)
    end

    def create(attrs)
      u = self.new(attrs)
      u.node = $neo.create_node(attrs)
      $neo.add_label(u.node, "Image")
      u
    end

    def find(image_id)
      query =<<-CYPHER
        MATCH (i:Image {image_id: {image_id}})
        RETURN i
      CYPHER

      nodes = $neo.execute_query(query, {image_id: image_id})

      convert_from_node nodes["data"].try(:first).try(:first)
    end

    def find_or_create(attrs)
      self.find(attrs[:image_id]) || self.create(attrs)
    end

    def convert_from_nodes(nodes)
      (nodes["data"] || []).map do |node|
        convert_from_node(node.first)
      end
    end

    def convert_from_node(node)
      if node
        return_node = self.new({})
        return_node.image_id = node["data"]["image_id"]
        return_node.url = node["data"]["url"]
        return_node.height = node["data"]["height"]
        return_node.width = node["data"]["width"]
        return_node.node = node
      end

      return_node || nil
    end
  end
end