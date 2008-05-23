module AssetServicesHelper
  def get_protocols
    ['Select a protocol...'] + AssetService.accepted_protocols
  end
end
