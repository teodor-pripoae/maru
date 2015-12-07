defmodule Maru.Plugs.Version do
  @moduledoc """
  This module is a plug, fetch `version` from connect and wirte to private variable `maru_version`.
  """

  alias Plug.Conn

  @doc false
  def init(opts) do
    {strategy, options} = opts |> Keyword.pop :using, :path
    unless strategy in [:path, :param, :accept_version_header] do
      IO.write :stderr, "Unsupported versioning strategy: #{strategy}, Ignore."
    end
    {strategy, options}
  end

  @doc false
  def call(conn, {:path, _opts}) do
    case conn.private do
      %{ maru_resource_path: [version | rest],
         maru_route_path:    route_path
       } -> conn
         |> Conn.put_private(:maru_resource_path, rest)
         |> Conn.put_private(:maru_route_path, route_path ++ [version])
         |> Conn.put_private(:maru_version, version)
      _  -> conn
    end
  end

  def call(conn, {:param, opts}) do
    case opts |> Keyword.get(:parameter, :apiver) do
      nil ->
        conn
      key ->
        version = conn.params[to_string(key)]
        conn |> Conn.put_private(:maru_version, version)
    end
  end

  def call(conn, {:accept_version_header, _opts}) do
    case Conn.get_req_header(conn, "accept-version") do
      [version] -> conn |> Conn.put_private(:maru_version, version)
      _         -> conn
    end
  end

  def call(conn, _) do
    conn
  end
end
