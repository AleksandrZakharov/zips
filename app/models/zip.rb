class Zip
  
  include ActiveModel::Model

  attr_accessor :id, :city, :state, :population

	def self.mongo_client
		Mongoid::Clients.default
	end

	def self.collection
		self.mongo_client['zips']
	end

  def initialize(params={})
    #switch between both internal and external views of id and population
    @id=params[:_id].nil? ? params[:id] : params[:_id]
    @city=params[:city]
    @state=params[:state]
    @population=params[:pop].nil? ? params[:population] : params[:pop]
  end

	def self.all(prototype={}, sort={:population=>1}, offset=0, limit=100)
    #map internal :population term to :pop document term
    tmp = {} #hash needs to stay in stable order provided
    sort.each {|k,v| 
      k = k.to_sym==:population ? :pop : k.to_sym
      tmp[k] = v  if [:city, :state, :pop].include?(k)
    }
    sort=tmp

    #convert to keys and then eliminate any properties not of interest
    prototype=prototype.symbolize_keys.slice(:city, :state) if !prototype.nil?

    Rails.logger.debug {"getting all zips, prototype=#{prototype}, sort=#{sort}, offset=#{offset}, limit=#{limit}"}

    result=collection.find(prototype)
          .projection({_id:true, city:true, state:true, pop:true})
          .sort(sort)
          .skip(offset)
    result=result.limit(limit) if !limit.nil?

    return result
  end

  def self.find id
    Rails.logger.debug {"getting zip #{id}"}

    doc=collection.find(:_id=>id)
                  .projection({_id:true, city:true, state:true, pop:true})
                  .first
    return doc.nil? ? nil : Zip.new(doc)
  end 
  def save
    Rails.logger.debug{"saving #{self}"}
    result = self.class.collection.insert_one(_id: @id, city: @city, state: @state, pop: @population)
    @id=result.inserted_id
  end

  def update(updates)
    Rails.logger.debug {"updating #{self} with #{updates}"}
    updates[:pop] = updates[:population] if !updates[:population].nil?
    updates.slice!(:city, :state, :pop) if !updates.nil?
    self.class.collection.find(_id:@id).update_one(updates)
  end

  def destroy
    Rails.logger.debug {"destroying #{self}"}
    self.class.collection.find(_id: @id).delete_one
  end
end


