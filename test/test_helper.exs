ExUnit.start()

Mox.defmock(IPNClientMock, for: Tipalti.IPN.Client.Behavior)
Mox.defmock(BodyReaderMock, for: BodyReader)

Application.put_env(:tipalti, :system_time_module, SystemTimeMock)
Application.put_env(:tipalti, :api_client_module, ClientMock)
Application.put_env(:tipalti, :ipn_client_module, IPNClientMock)
Application.put_env(:tipalti, :ipn_body_reader, BodyReaderMock)
