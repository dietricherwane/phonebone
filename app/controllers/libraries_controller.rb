class LibrariesController < ApplicationController
  def index

  end

  def crawler
    @@url_depart = 'http://togophonebook.com'
    @@rg1 = /<\/div><div class="cols3"><ul><li>/ #regex1 niveau1
    @@rg2 = /<div class="clear">/ #regex2 niveau1 et niveau2
    @@rg3 = /<ul class="linkList">/ #regex1 niveau2
    @@rg4 = /lst=\[/ #regex1 niveau3
    @@rg5 = /\];/ #regex2 niveau3
    @@rg6 = /Pr&#233;c&#233;dent/ #regex1 de recuperation des pages suivantes
    @@rg7 = /Suivant/ #regex2 de recuperation des pages suivantes
    @@rg8 = /<div id="generic">/ #regex1 niveau4
    @@rg9 = /<div id="showcaseProfile" name="showcaseProfile">/ #regex2 niveau4
    @@rg_link_lv1 = /<a href=".*?">/ #regex de recuperation des catégories (niveau1) et des sous catégories (niveau2)
    @@rg_link_lv3 = /\[.*?\]/ #regex de recuperation de la liste des POI (niveau3)
    @@name = /<span id="listingName" class="">.*?<\/span>/
    @@address = /<span id="street-address" class="street-address">.*?<\/span>/
    @@tel = /<span class="abbr">.*?Tél\..*?<\/span><\/abbr><span class="value">.*?<\/span>/
    @@fax = /<abbr class="type" title="work"><span class="abbr">.*?ax.*?<\/span><\/abbr><span class="value">.*?<\/span>/
    @@email = /<img src=".*?" alt="Envoyer un email" height="16" \/>/
    @@website = /onclick="return webLink(.*?);" >.*?<\/a>/
    @@location_data = {} #hash pour le formatage des données



    def fetch_url(url)
      @html_text = Net::HTTP.get(URI.parse(URI.encode(url)))   #encodage, analyse, puis récupération du contenu html de l'url
    end

    def retrieve_links_list(html_text, rg1, rg2)
      @x = rg1.match(html_text)
      @y = @x.post_match   #récupération du texte se trouvant après rg1
      @z = rg2.match(@y)
      @links_list = @z.pre_match   #récupération du texte se trouvant avant rg2 (liste de liens nous intéressant)
    end

    def table_of_links(rg_link, links_list)
      @i = 0   #initialisation
      @t = Array.new   #initialisation
      @_link = ''   #initialisation
      @link_tag = rg_link.match(links_list).to_s   #initialisation
      while @link_tag != ''
        @link_tag = rg_link.match(links_list).to_s   #récupération parmi la liste de l'url correspondant au modèle
        if @link_tag == ''
          break
        end
        if rg_link == @@rg_link_lv1   #valable pour les niveaux 1 et 2
          @_link = @link_tag.split('"')   #separation du lien en fonction de => "
          @_link[1] = @_link[1].sub('.', '')   #remplacement de '.' par '' car les liens sont de la forme <a href="./alimentation/">
          @t[@i] = @@url_depart+@_link[1]
          #puts @t[@i]
        end
        if rg_link == @@rg_link_lv3   #valable pour le niveau3
          @_link = @link_tag.split("'")
          @t[@i] = @_link[1]
          #puts @t[@i]
        end
        if rg_link == @@name   #valable pour le niveau4
          @_link = @link_tag.split('>')
          @_link = @_link[1].split('<')
          @t[@i] = @_link[0]
        end
        if rg_link == @@address   #valable pour le niveau4
          @_link = @link_tag.split('>')
          @_link = @_link[1].split('<')
          @t[@i] = @_link[0]
        end
        if rg_link == @@tel   #valable pour le niveau4
          @_link = @link_tag.split('>')
          @_link = @_link[4].split('<')
          @t[@i] = @_link[0]
        end
        if rg_link == @@fax   #valable pour le niveau4
          @_link = @link_tag.split('>')
          @_link = @_link[5].split('<')
          @t[@i] = @_link[0]
        end
        if rg_link == @@email   #valable pour le niveau4
          @_link = @link_tag.split('"')
          @_link[1] = @_link[1].sub('.', '')
          @t[@i] = @@url_depart+@_link[1]
        end
        if rg_link == @@website   #valable pour le niveau4
          @_link = @link_tag.split('>')
          @_link = @_link[1].split('<')
          @t[@i] = @_link[0]
        end
        puts @t[@i]
        @i += 1   #incrémentation du compteur
        links_list = links_list.sub(@link_tag, '')   #suppression du lien stocké dans la liste de liens
      end
      @t   #la méthode retourne un tableau contenant la liste de liens
    end

    def retrieve_location_data(url)
      #NIVEAU1#
      puts '****NIVEAU1****'
      @html_text = fetch_url(url)
      @links_list = retrieve_links_list(@html_text, @@rg1, @@rg2)
      @t_lv1 = table_of_links(@@rg_link_lv1, @links_list)
      puts
      #NIVEAU1#

      #NIVEAU2#
      puts '****NIVEAU2****'
      @t_lv1.each do |t_lv1|
        @html_text = fetch_url(t_lv1)
        @links_list = retrieve_links_list(@html_text, @@rg3, @@rg2)
        @t_lv2 = table_of_links(@@rg_link_lv1, @links_list)
        puts
      #Tableau contenant les sous-categories en plus les liens vers les pages suivantes de chacune
        @t_next = Array.new
        @t_lv2.each do |t|
          @t_next = @t_next << t
          puts '****LIENS VERS LES PAGES SUIVANTES; traitement de: '+t
          @html_text = fetch_url(t)
          @links_list = retrieve_links_list(@html_text, @@rg6, @@rg7)
          @t_temp = table_of_links(@@rg_link_lv1, @links_list)
          @t_next = @t_next + @t_temp   #concatenation de la sous categorie et de ses pages suivantes
          puts 'Sous catégories + liens vers leurs pages suivantes'
          @t_next.each do |t|
            puts t
          end
          puts 'FIN des sous-catégories + liens vers leurs pages suivantes'
          puts
        end
        @t_lv2 = @t_next   #on obtient un tableau contenant les sous-categories en plus les liens vers les pages suivantes de chacune
      #Tableau contenant les sous-categories en plus les liens vers les pages suivantes de chacune

      #NIVEAU3#
        puts '****NIVEAU3****'
        @t_lv2.each do |t_lv2|
          @html_text = fetch_url(t_lv2)
          @links_list = retrieve_links_list(@html_text, @@rg4, @@rg5)
          @t_lv3 = table_of_links(@@rg_link_lv3, @links_list)

          #NIVEAU4
          puts '****NIVEAU4****'
          @t_lv3.each do |t_lv3|
            @html_text = fetch_url(t_lv3)
            @links_list = retrieve_links_list(@html_text, @@rg8, @@rg9)

            @name = table_of_links(@@name, @links_list).to_s
            @address = table_of_links(@@address, @links_list).to_s
            @tel = table_of_links(@@tel, @links_list)
            @fax = table_of_links(@@fax, @links_list)
            @email = table_of_links(@@email, @links_list)
            @website = table_of_links(@@website, @links_list)
            puts

            @@location_data.merge!({
              @name => {
                'country' => 'Togo',
                'address' => @address,
                'phone-number' => @tel,
                'fax-number' => @fax,
                'email' => @email,
                'website' => @website
              }
            })

            Library.create(:name => @name, :address => @address, :telephone=> @tel.to_s, :fax => @fax.to_s, :email => @email.to_s, :website => @website.to_s)
          end
          #puts '****HASH****'
          puts @@location_data.size
          #puts
          #  @@location_data.each_pair {|key, value|
          #    puts "Location: #{key}"
          #    value.each_pair {|key2, value2|
          #      puts "#{key2} => #{value2}"
          #    }
          #    puts
          #  }
          #NIVEAU4
        end
      #NIVEAU3#
      end
      #NIVEAU2#
      @@location_data   #on obtient un hash contenant la liste des POI avec leurs fiches de contacts
    end
    retrieve_location_data('http://togophonebook.com')
    flash[:notice] = 'Successfully populated database.'
    redirect_to locations_path
  end
end
