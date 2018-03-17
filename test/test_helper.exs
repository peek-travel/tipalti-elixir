ExUnit.start()

Application.put_env(:tipalti, :system_time_module, SystemTimeMock)
Application.put_env(:tipalti, :api_client_module, ClientMock)

{:ok, files} = File.ls("./test/support")

Enum.each(files, fn file ->
  Code.require_file("support/#{file}", __DIR__)
end)
