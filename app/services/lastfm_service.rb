class LastfmService
  LAST_FM_API_KEY = ENV["LAST_FM_API_KEY"]
  attr_accessor :artist_name
  def initialize(params = {artist_name: "",user: User.new})
    @artist_name = params[:artist_name]
    @user = params[:user]
    @search_history_quantity = 10
  end

  # final_res_body_format = {
  #   tracks: [],
  #   similar_artists: [],
  #   msg: [],
  #   search_logs: []  
  # }
  def artist_tracks_and_similar_artists(final_res_body_format)
    final_response = final_res_body_format
    response = get_similar_artists
    unless (response['error'])
      similar_artists = response["artist"]["similar"]["artist"]
      search_history_log_maker
      final_response[:similar_artists] = similar_artists.map {|similar_artist_info| similar_artist_info["name"]}
      response_tracks = get_artist_tracks
      response_tracks["toptracks"]["track"].each do |track_info|
        final_response[:tracks] << track_info["name"]
      end
      final_response[:search_logs] = get_user_search_logs
    else
      final_response[:msg] = response['message']
    end  
    final_response
  end

  def get_artist_info_url
    "http://ws.audioscrobbler.com/2.0/?method=artist.getinfo&artist=#{@artist_name}&api_key=#{ENV["LAST_FM_API_KEY"]}&format=json"
  end

  def get_artist_tracks_url
    "http://ws.audioscrobbler.com/2.0/?method=artist.gettoptracks&artist=#{@artist_name}&api_key=#{ENV["LAST_FM_API_KEY"]}&format=json"
  end

  def get_similar_artists
    artist_info = HTTParty.get(get_artist_info_url)
    response = JSON.parse(artist_info.body)
  end

  def get_artist_tracks
    artist_tracks = HTTParty.get(get_artist_tracks_url)
    response = JSON.parse(artist_tracks.body)
  end

  def search_history_log_maker
    SearchHistoryService.new(@user).insert_into_user_search(@artist_name)
  end

  def get_user_search_logs
    search_logs = []
    get_last_n_searches.each do |search_history|
      search_logs.push({
        search_key: search_history.search_key,
        searched_at: search_history.created_at
      })
    end
    search_logs
  end

  def get_last_n_searches
    @user.search_histories.order(created_at: 'DESC').limit(@search_history_quantity)
  end
end