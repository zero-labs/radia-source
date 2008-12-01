services = YAML.load_file("#{RAILS_ROOT}/config/services.yml")

$playout = services['playout']
$archive = services['archive']