class LibrariesController < ApplicationController
  def index

  end

  def crawler
    @@url_depart = 'http://togophonebook.com'
    @@rg1 = /<\/div><div class="cols3"><ul><li>/ #regex1 LV1
    @@rg2 = /<div class="clear">/ #regex2 LV1 et LV2
    @@rg3 = /<ul class="linkList">/ #regex1 LV2
    @@rg4 = /lst=\[/ #regex1 LV3
    @@rg5 = /\];/ #regex2 LV3
    @@rg6 = /Pr&#233;c&#233;dent/ #regex1 de recuperation des pages suivantes
    @@rg7 = /Suivant/ #regex2 de recuperation des pages suivantes
    @@rg8 = /<div id="generic">/ #regex1 LV4
    @@rg9 = /<div id="showcaseProfile" name="showcaseProfile">/
    @@rg_link_lv1 = /<a href=".*?">/ #regex de recuperation des liens LV1 et LV2
    @@rg_link_lv3 = /\[.*?\]/ #regex de recuperation des liens LV3
    @@name = /<span id="listingName" class="">.*?<\/span>/
    @@address = /<span id="street-address" class="street-address">.*?<\/span>/
    @@tel = /<span class="abbr">.*?Tél\..*?<\/span><\/abbr><span class="value">.*?<\/span>/
    @@fax = /<abbr class="type" title="work"><span class="abbr">.*?ax.*?<\/span><\/abbr><span class="value">.*?<\/span>/
    @@mail = /<img src=".*?" alt="Envoyer un email" height="16" \/>/
    @@weblink = /onclick="return webLink(.*?);" >.*?<\/a>/
    @@location_data = {}



    def fetch_url(url)
      @html_text = Net::HTTP.get(URI.parse(URI.encode(url)))
    end

    def retrieve_links_list(html_text, rg1, rg2)
      @x = rg1.match(html_text)
      @y = @x.post_match
      @z = rg2.match(@y)
      @links_list = @z.pre_match
    end

    def table_of_links(rg_link, links_list)
      @i = 0
      @t = Array.new
      @_link = ''
      @link_tag = rg_link.match(links_list).to_s
      while @link_tag != ''
        @link_tag = rg_link.match(links_list).to_s
        if @link_tag == ''
          break
        end
        if rg_link == @@rg_link_lv1              #valable pour les levels 1 et 2
          @_link = @link_tag.split('"')          #separation du lien en fonction de => "
          @_link[1] = @_link[1].sub('.', '')     #remplacement du point par un vide car les liens sont de la forme <a href="./alimentation/">
          @t[@i] = @@url_depart+@_link[1]
        end
        if rg_link == @@rg_link_lv3             #valable pour le level 3
          @_link = @link_tag.split("'")
          @t[@i] = @_link[1]
        end
        if rg_link == @@name
          @_link = @link_tag.split('>')
          @_link = @_link[1].split('<')
          @t[@i] = @_link[0]
        end
        if rg_link == @@address
          @_link = @link_tag.split('>')
          @_link = @_link[1].split('<')
          @t[@i] = @_link[0]
        end
        if rg_link == @@tel
          @_link = @link_tag.split('>')
          @_link = @_link[4].split('<')
          @t[@i] = @_link[0]
        end
        if rg_link == @@fax
          @_link = @link_tag.split('>')
          @_link = @_link[5].split('<')
          @t[@i] = @_link[0]
        end
        if rg_link == @@mail
          @_link = @link_tag.split('"')
          @_link[1] = @_link[1].sub('.', '')
          @t[@i] = @@url_depart+@_link[1]
        end
        if rg_link == @@weblink
          @_link = @link_tag.split('>')
          @_link = @_link[1].split('<')
          @t[@i] = @_link[0]
        end
        puts @t[@i]
        @i = @i+1
        links_list = links_list.sub(@link_tag, '')  #suppression du lien stocké dans la liste de liens
      end
      @t
    end

    def retrieve_location_data(url)
      #NIVEAU1#
      puts '****NIVEAU1'
      @html_text = fetch_url(url)
      @links_list = retrieve_links_list(@html_text, @@rg1, @@rg2)
      @t_lv1 = table_of_links(@@rg_link_lv1, @links_list)
      #NIVEAU1#

      #NIVEAU2#
      puts '****NIVEAU2'
      @t_lv1.each do |t_lv1|
        @html_text = fetch_url(t_lv1)
        @links_list = retrieve_links_list(@html_text, @@rg3, @@rg2)
        @t_lv2 = table_of_links(@@rg_link_lv1, @links_list)

      #Tableau contenant les categories NIVEAU2 + les liens vers la page suivante de chacune
        @t_next = Array.new
        @t_lv2.each do |t|
          @t_next = @t_next << t
          puts '****LIENS VERS LES PAGES SUIVANTES'
          puts t
          @html_text = fetch_url(t)
          @links_list = retrieve_links_list(@html_text, @@rg6, @@rg7)
          @t_temp = table_of_links(@@rg_link_lv1, @links_list)
          @t_next = @t_next + @t_temp   #concatenation de la sous categorie et de ses pages suivantes
          puts 'tableau niveau2 + liens vers les pages suivantes'
          @t_next.each do |t|
            puts t
          end
          puts 'FIN tableau niveau2 + liens vers les pages suivantes'
        end
        @t_lv2 = @t_next
      #Tableau contenant les categories LEVEL2 + les liens vers la page suivante de chacune

      #NIVEAU3#
        puts '****NIVEAU3'
        @t_lv2.each do |t_lv2|
          @html_text = fetch_url(t_lv2)
          @links_list = retrieve_links_list(@html_text, @@rg4, @@rg5)
          @t_lv3 = table_of_links(@@rg_link_lv3, @links_list)
          puts '**********'

          #NIVEAU4
          @t_lv3.each do |t_lv3|
            @html_text = fetch_url(t_lv3)
            @links_list = retrieve_links_list(@html_text, @@rg8, @@rg9)
            puts 'name:'
            @name = table_of_links(@@name, @links_list).to_s
            puts 'address:'
            @address = table_of_links(@@address, @links_list).to_s
            puts 'tel:'
            @tel = table_of_links(@@tel, @links_list)
            puts 'fax:'
            @fax = table_of_links(@@fax, @links_list)
            puts 'e-mail:'
            @mail = table_of_links(@@mail, @links_list)
            puts 'weblink:'
            @weblink = table_of_links(@@weblink, @links_list)
            @@location_data.merge!({
              @name => {
                'country' => 'Togo',
                'address' => @address,
                'phone-number' => @tel,
                'fax-number' => @fax,
                'e-mail' => @mail,
                'weblink' => @weblink
              }
            })
            Library.create(:name => @name, :address => @address, :telephone=> @tel.to_s, :fax => @fax.to_s, :email => @mail.to_s, :website => @weblink.to_s)
          end
          puts '**************HASH'
          puts @@location_data.size
            @@location_data.each_pair {|key, value|
              puts "Location: #{key}"
              @nom = key
              value.each_pair {|key2, value2|
                puts "#{key2} => #{value2}"
              }

            }
          #NIVEAU4
        end
      #NIVEAU3#
      end
      #NIVEAU2#
      @@location_data
    end
    retrieve_location_data('http://togophonebook.com')
    flash[:notice] = "Successfully populated database."
    redirect_to locations_path
  end
end
