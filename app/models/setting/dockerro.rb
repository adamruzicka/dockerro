class Setting::Dockerro < Setting
  def self.load_defaults
    return unless super

    self.transaction do
      [
        self.set('dockerro_builder_image', N_("Name of image used for building new images"), 'dockerhost-builder')
      ].each { |s| self.create! s.update(:category => "Setting::Dockerro") }
    end
  end
end
