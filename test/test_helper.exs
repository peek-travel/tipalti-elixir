ExUnit.start()

Application.put_env(:tipalti, :system_time_module, SystemTimeMock)
Application.put_env(:tipalti, :api_client_module, ClientMock)
Application.put_env(:tipalti, :ipn_client_module, IPNClientMock)
Application.put_env(:tipalti, :ipn_body_reader, BodyReaderMock)

{:ok, files} = File.ls("./test/support")

Enum.each(files, fn file ->
  Code.require_file("support/#{file}", __DIR__)
end)
