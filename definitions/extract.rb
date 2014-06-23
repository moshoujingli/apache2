define :extract, :dest=>"/tmp/",:src =>nil do
    if params[:src] == nil
        log "extract not set src" do
            level :error
        end
    else
        src = params[:src];
        dest = params[:dest];
        bash 'extract' do
          cwd ::File.dirname(src)
          code <<-EOH
            mkdir -p #{dest}
            tar xzf #{src} -C #{dest}
            mv #{dest}/*/* #{dest}/
            EOH
          not_if { ::File.exists?(dest) }
        end
    end
end