defmodule Notespump do
  @moduledoc """
  The Notespump module contains functions that help us push the notes we get from C-OMS into CCA DB.
  We end up calling the Add Notes API against UNO.
  """

  @doc """
  These are the module attributes or constants that are used in this module.
  `login_url`       UNO login url
  `username`        User Name for login
  `password`        Password for login
  `logout_url`      UNO Logout url  
  `notes_save_url`  UNO API endpoint for saving customer note
  `queue_dir`       Path to the c-oms files
  """
  @login_url "https://preprod.uno.walmart.com/uno-webservices/ws/security/checkLogin"
  @username "rghosh"
  @password "P@ssword1"

  @logout_url "https://preprod.uno.walmart.com/uno-webservices/ws/security/logout"

  @notes_save_url "https://preprod.uno.walmart.com/uno-webservices/ws/customer/"

  @queue_dir "../../notespump/queue/"

  @doc """
  The `uno_login/0` function is used to get call the login API for UNO, get the cookie from the response and send it back to the caller to be used for the other service calls.
  """
  def uno_login do
    %HTTPotion.Response{headers: %HTTPotion.Headers{hdrs: %{"uno_token" => cookie}}, status_code: _} = HTTPotion.post @login_url, [body: "username=" <> URI.encode_www_form(@username) <> "&password=" <> URI.encode_www_form(@password), headers: ["User-Agent": "My App", "Content-Type": "application/x-www-form-urlencoded"]]

    cookie      
  end

  @doc """
  This function `uno_logout/1` takes in the cookie that was created y `uno_login/0` and calls the UNO API to log out the user.
  This is not used currently.
  """
  def uno_logout(cookie) do
    HTTPotion.get @logout_url, [headers: ["UNO_TOKEN": cookie, "Content-Type": "application/json", "Accept-Encoding": "application/json"]]
  end

  @doc """
  The `parse_coms_note/1` function parses the given input into a `Note%{}` struct
  """
  def parse_coms_note(coms_note) do
    %{"payload" => %{"customerNotesBatch" => [%{"createdDate" => createDate, "csAgent" => agent, "customerAccountId" => customerId, "note" => note, "reasonCode" => reasonCode, "reasonDescription" => reasonDesc}]}} = Poison.Parser.parse!(coms_note)
    %Note{noteText: note, reasonCode: reasonCode, reasonDescription: reasonDesc, enteredBy: agent, contactTime: createDate, contactReference: customerId}
  end

  @doc """
  `prepare_note/1` takens in the `%Note{}` struct, extracts the customer from the note and converts the note into JSON format, it then returns a `{jsonNote, customerId}` tuple
  """
  def prepare_note(%Note{} = note) do
    jsonNote = Poison.encode!(note)
    
    customerId = note.contactReference
    |> String.downcase 
    |> String.replace(~r/([0-9a-fA-F]{8})([0-9a-fA-F]{4})([0-9a-fA-F]{4})([0-9a-fA-F]{4})([0-9a-fA-F]+)/, "\\1-\\2-\\3-\\4-\\5")

    {jsonNote, customerId}
  end

  @doc """
  `save_note/2` takes in the `{jsonNote, customerId}` tuple and the cookie to actually call the UNO API to save the note
  """
  def save_note({note, customerId}, cookie) do
    response = HTTPotion.post @notes_save_url <> customerId <> "/customernotes", [body: note, headers: ["User-Agent": "My App", "Content-Type": "application/json", "Accept": "application/json", "UNO_TOKEN": cookie]]
    IO.inspect response
  end

  @doc """
  `find_files/0` finds all the files in the `@queue_dir` dir
  """
  def find_files do
    File.ls!(@queue_dir) 
    |> Enum.map(&Path.join(@queue_dir, &1)) 
    |> Enum.filter(fn file -> String.ends_with?(file, ".txt") end)
  end

  @doc """
  This is the `main/0` function that triggers all the steps.
  `find_files/0` is called to get the list of all eligible files.
  If there are more than 0 files, then a process is spawned for each file to:
  `File.read(file)` and the contents of the file is used in the following pipeline.
    contents
    |> parse_coms_note
    |> prepare_note
    |> save_note(cookie)
  
  Usage: `Notespump.main`

  """
  def main do
    files = find_files()
    
    case Enum.count(files) do
      0 -> IO.puts "No files found"
      _ -> 
        cookie = uno_login()

        Enum.each(files, fn file -> 
                              spawn fn -> 
                                  {:ok, contents} = File.read(file)
                                  
                                  contents
                                  |> parse_coms_note
                                  |> prepare_note
                                  |> save_note(cookie)

                                  IO.puts "Done processing file " <> IO.inspect(file) # <> " Status Code = " <> Integer.to_string(status_code)
                               end 
                          end)
    end
  end
end
