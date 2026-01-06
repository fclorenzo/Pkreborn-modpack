class PokeBattle_Pokemon
  alias shine_initialize initialize
  def initialize(species, level, player = $Trainer, withMoves = true, form = 0)
    # 1. Run original initialization
    shine_initialize(species, level, player, withMoves, form)

    # 2. Skip if debug modes are on (safety)
    return if $game_switches[:Full_IVs] || $game_switches[:Empty_IVs_Password]

    # Get data from cache safely
    dex_data = $cache.pkmn[@species, @form]

    if  isShiny?
      # Part A: Guaranteed 2 Perfect IVs
      stats_to_max = [0, 1, 2, 3, 4, 5].sample(2)
      for i in stats_to_max
        @iv[i] = 31
      end
      self.calcStats

      # Part B: Increased Item Chance
      if @item.nil?
        # Retrieve wild items individually. 
        # We use 'rescue nil' to prevent crashes if a specific method is missing in this engine version.
        common   = dex_data.WildItemCommon   rescue nil
        uncommon = dex_data.WildItemUncommon rescue nil
        rare     = dex_data.WildItemRare     rescue nil
        
        # Only proceed if at least one item exists
        if common || uncommon || rare
          roll = rand(100)
          
          # Boosted Odds Logic:
          # 1. Try for RARE (15%)
          if roll < 15 && rare
            @item = rare
          # 2. If Rare failed (or didn't exist), try UNCOMMON (next 30%)
          #    (This check covers rolls 0-44 effectively, ensuring fall-through if Rare was missing)
          elsif roll < 45 && uncommon
            @item = uncommon
          # 3. If others failed, give COMMON (Remaining 55%)
          elsif common
            @item = common
          end
        end
      end
    end
  end
end