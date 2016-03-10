# encoding: utf-8
require 'spec_helper'

describe 'LesBonnesChoses' do
  before do
    @api = Prismic.api('https://lesbonneschoses.cdn.prismic.io/api', nil)
    @master_ref = @api.master_ref
  end

  describe '/api' do
    it 'API works' do
      @api.should_not be_nil
    end
  end

  describe 'query' do
    it 'queries everything and returns 20 documents' do
      @api.form('everything').submit(@master_ref).size.should == 20
      @api.form('everything').submit(@master_ref).results.size.should == 20
    end

    it 'queries macarons (using a predicate) and returns 7 documents' do
      @api.query('[[:d = any(document.tags, ["Macaron"])]]')
        .results.size.should == 7
      @api.query('[[:d = any(document.tags, ["Macaron"])]]').size.should == 7
    end

    it 'queries macarons (using a form) and returns 7 documents' do
      @api.form('macarons').submit(@master_ref).results.size.should == 7
      @api.form('macarons').submit(@master_ref).size.should == 7
    end

    it 'queries macarons or cupcakes (using a form + a predicate) and returns 11 documents' do
      @api.form('products')
        .query('[[:d = any(document.tags, ["Cupcake", "Macaron"])]]')
        .submit(@master_ref).results.size.should == 11
      @api.form('products')
        .query('[[:d = any(document.tags, ["Cupcake", "Macaron"])]]')
        .submit(@master_ref).size.should == 11
    end
  end

  describe 'pagination' do
    it 'works in basic cases' do
      documents = @api.form('everything').submit(@master_ref)
      documents.page.should == 1
      documents.results_per_page.should == 20
      documents.results_size.should == 20
      documents.total_results_size.should == 40
      documents.total_pages.should == 2
      documents.next_page.should == 'https://d2aw36oac6sa9o.cloudfront.net/api/documents/search?ref=UlfoxUnM08QWYXdl&page=2&pageSize=20'
      documents.prev_page.should == nil
    end
    it 'works when passing nil' do
      documents = @api.form('everything').page(nil).submit(@master_ref)
      documents.page.should == 1
      documents.results_per_page.should == 20
      documents.results_size.should == 20
      documents.total_results_size.should == 40
      documents.total_pages.should == 2
      documents.next_page.should == 'https://d2aw36oac6sa9o.cloudfront.net/api/documents/search?ref=UlfoxUnM08QWYXdl&page=2&pageSize=20'
      documents.prev_page.should == nil
    end
    it 'works on page 2' do
      documents = @api.form('everything').page("2").submit(@master_ref)
      documents.page.should == 2
      documents.results_per_page.should == 20
      documents.results_size.should == 20
      documents.total_results_size.should == 40
      documents.total_pages.should == 2
      documents.next_page.should == nil
      documents.prev_page.should == 'https://d2aw36oac6sa9o.cloudfront.net/api/documents/search?ref=UlfoxUnM08QWYXdl&page=1&pageSize=20'
    end
    it 'works on page 2 with a pagination step of 10' do
      documents = @api.form('everything').page('2').page_size('10').submit(@master_ref)
      documents.page.should == 2
      documents.results_per_page.should == 10
      documents.results_size.should == 10
      documents.total_results_size.should == 40
      documents.total_pages.should == 4
      documents.next_page.should == 'https://d2aw36oac6sa9o.cloudfront.net/api/documents/search?ref=UlfoxUnM08QWYXdl&page=3&pageSize=10'
      documents.prev_page.should == 'https://d2aw36oac6sa9o.cloudfront.net/api/documents/search?ref=UlfoxUnM08QWYXdl&page=1&pageSize=10'
    end
    it 'works when passing nil' do
      documents = @api.form('everything').page(nil).submit(@master_ref)
      documents.page.should == 1
      documents.results_per_page.should == 20
      documents.results_size.should == 20
      documents.total_results_size.should == 40
      documents.total_pages.should == 2
      documents.next_page.should == 'https://d2aw36oac6sa9o.cloudfront.net/api/documents/search?ref=UlfoxUnM08QWYXdl&page=2&pageSize=20'
      documents.prev_page.should == nil
    end
  end

  describe 'API::Document' do
    before do
      @document = @api.form('everything').query('[[:d = at(document.id, "UlfoxUnM0wkXYXbh")]]').submit(@master_ref)[0]
    end

    it 'Operator [] works on document' do
      @document['job-offer.name'].as_html(nil).should == '<h1>Pastry Dresser</h1>'
    end

    it 'Operator [] returns nil if wrong type' do
      @document['product.name'].should == nil
    end

    it 'Operator [] raises error if field is nonsense' do
      expect {
        @document['blablabla']
      }.to raise_error(ArgumentError, 'Argument should contain one dot. Example: product.price')
    end
  end

  describe 'API::Documents' do
    before do
      @documents = @api.form('everything').submit(@master_ref)
    end

    it 'has a working [] operator' do
      @documents[0].slug.should == @documents.results[0].slug
    end
    it 'has a proper size' do
      @documents.length.should == 20
      @documents.size.should == 20
    end
    it 'has a proper each method' do
      array = []
      @documents.each {|document| array << document.slug }
      array.join(' ').should == 'art-director store-intern content-director ganache-specialist community-manager oven-instrumentist paris-saint-lazare tokyo-roppongi-hills london-covent-garden paris-champ-elysees new-york-fifth-avenue pastry-dresser exotic-kiwi-pie apricot-pie sweet-strawberry-pie woodland-cherry-pie cool-coconut-macaron salted-caramel-macaron the-end-of-a-chapter-the-beginning-of-a-new-one get-the-right-approach-to-ganache'
    end
    it 'is a proper Enumerable' do
      @documents.map {|document| document.slug }.join(' ').should == 'art-director store-intern content-director ganache-specialist community-manager oven-instrumentist paris-saint-lazare tokyo-roppongi-hills london-covent-garden paris-champ-elysees new-york-fifth-avenue pastry-dresser exotic-kiwi-pie apricot-pie sweet-strawberry-pie woodland-cherry-pie cool-coconut-macaron salted-caramel-macaron the-end-of-a-chapter-the-beginning-of-a-new-one get-the-right-approach-to-ganache'
    end
  end

  describe 'FetchLinks' do
    it 'Fetches additional data with DocumentLink' do
      documents = @api.form('everything')
        .query(Prismic::Predicates::at('document.id', 'UlfoxUnM0wkXYXbt'))
        .fetch_links('blog-post.author')
        .submit(@master_ref).results
      link = documents[0].get('blog-post.relatedpost')[0]
      link.get_text('blog-post.author').value.should == 'John M. Martelle, Fine Pastry Magazine'
    end
  end

  describe 'Fragments' do
    before do
      @link_resolver = Prismic.link_resolver("master"){|doc_link| "http://localhost/#{doc_link.id}" }
      @html_serializer = Prismic.html_serializer do |element, html|
        if element.is_a?(Prismic::Fragments::StructuredText::Block::Image)
          %(<img src="#{element.url}" alt="#{element.alt}" width="#{element.width}" height="#{element.height}" />)
        else
          nil
        end
      end
    end
    describe 'API::Fragments::StructuredText' do
      it "returns a correct as_html on a StructuredText with list, span, embed and image" do
        @api.form("everything")
          .query(%([[:d = at(document.id, "UlfoxUnM0wkXYXbX")]]))
          .submit(@master_ref)[0]['blog-post.body'].as_html(@link_resolver).gsub("&#39;", "'").should ==
            "<h1>Get the right approach to ganache</h1>\n\n"\
            "<p>A lot of people touch base with us to know about one of our key ingredients, and the essential role it plays in our creations: ganache.</p>\n\n"\
            "<p>Indeed, ganache is the macaron's softener, or else, macarons would be but tough biscuits; it is the cupcake's wrapper, or else, cupcakes would be but plain old cake. We even sometimes use ganache within our cupcakes, to soften the cake itself, or as a support to our pies' content.</p>\n\n"\
            "<h2>How to approach ganache</h2>\n\n"\
            "<p class=\"block-img\"><img src=\"https://d2aw36oac6sa9o.cloudfront.net/lesbonneschoses/ee7b984b98db4516aba2eabd54ab498293913c6c.jpg\" alt=\"\" width=\"640\" height=\"425\" /></p>\n\n"\
            "<p>Apart from the taste balance, which is always a challenge when it comes to pastry, the tough part about ganache is about thickness. It is even harder to predict through all the phases the ganache gets to meet (how long will it get melted? how long will it remain in the fridge?). "\
            "Things get a hell of a lot easier to get once you consider that there are two main ways to get the perfect ganache:</p>\n\n"\
            "<ul><li><strong>working from the top down</strong>: start with a thick, almost hard material, and soften it by manipulating it, or by mixing it with a more liquid ingredient (like milk)</li>"\
            "<li><strong>working from the bottom up</strong>: start from a liquid-ish state, and harden it by miwing it with thicker ingredients, or by leaving it in the fridge longer.</li></ul>\n\n"\
            "<p>We do hope this advice will empower you in your ganache-making skills. Let us know how you did with it!</p>\n\n"\
            "<h2>Ganache at <em>Les Bonnes Choses</em></h2>\n\n"\
            "<p>We have a saying at Les Bonnes Choses: &quot;Once you can make ganache, you can make anything.&quot;</p>\n\n"\
            "<p>As you may know, we like to give our workshop artists the ability to master their art to the top; that is why our Preparation Experts always start off as being Ganache Specialists for Les Bonnes Choses. That way, they're given an opportunity to focus on one exercise before moving on. "\
            "Once they master their ganache, and are able to provide the most optimal delight to our customers, we consider they'll thrive as they work on other kinds of preparations.</p>\n\n"\
            "<h2>About the chocolate in our ganache</h2>\n\n"\
            "<p>Now, we've also had a lot of questions about how our chocolate gets made. It's true, as you might know, that we make it ourselves, from Columbian cocoa and French cow milk, with a process that much resembles the one in the following Discovery Channel documentary.</p>\n\n"\
            "<div data-oembed=\"http://www.youtube.com/\" data-oembed-type=\"video\" data-oembed-provider=\"youtube\"><iframe width=\"459\" height=\"344\" src=\"http://www.youtube.com/embed/Ye78F3-CuXY?feature=oembed\" frameborder=\"0\" allowfullscreen></iframe></div>"
      end
      it "returns a correct as_html on a StructuredText with custom HTML serializer" do
        @api.form("everything")
          .query(%([[:d = at(document.id, "#{@api.bookmark('about')}")]]))
          .submit(@master_ref)[0]['article.content'].as_html(@link_resolver, @html_serializer).gsub("&#39;", "'").should ==
              "<h2>A tale of pastry and passion</h2>\n\n"\
              "<p>As a child, Jean-Michel Pastranova learned the art of fine cuisine from his grand-father, Jacques Pastranova, who was the creator of the &quot;taste-design&quot; art current, and still today an unmissable reference of forward-thinking in cuisine. At first an assistant in his grand-father's kitchen, Jean-Michel soon found himself fascinated by sweet flavors and the tougher art of pastry, drawing his own path in the ever-changing cuisine world.</p>\n\n"\
              "<p>In 1992, the first Les Bonnes Choses store opened on rue Saint-Lazare, in Paris (<a href=\"http://localhost/UlfoxUnM0wkXYXbb\">we're still there!</a>), much to everyone's surprise; indeed, back then, it was very surprising for a highly promising young man with a preordained career as a restaurant chef, to open a pastry shop instead. But soon enough, contemporary chefs understood that Jean-Michel had the drive to redefine a new nobility to pastry, the same way many other kinds of cuisine were being qualified as &quot;fine&quot;.</p>\n\n"\
              "<p>In 1996, meeting an overwhelming demand, Jean-Michel Pastranova opened <a href=\"http://localhost/UlfoxUnM0wkXYXbP\">a second shop on Paris's Champs-Élysées</a>, and <a href=\"http://localhost/UlfoxUnM0wkXYXbr\">a third one in London</a>, the same week! Eventually, Les Bonnes Choses gained an international reputation as &quot;a perfection so familiar and new at the same time, that it will feel like a taste travel&quot; (New York Gazette), &quot;the finest balance between surprise and comfort, enveloped in sweetness&quot; (The Tokyo Tribune), &quot;a renewal of the pastry genre (...), the kind that changed the way pastry is approached globally&quot; (The San Francisco Gourmet News). Therefore, it was only a matter of time before Les Bonnes Choses opened shops in <a href=\"http://localhost/UlfoxUnM0wkXYXbc\">New York</a> (2000) and <a href=\"http://localhost/UlfoxUnM0wkXYXbU\">Tokyo</a> (2004).</p>\n\n"\
              "<p>In 2013, Jean-Michel Pastranova stepped down as the CEO and Director of Workshops, remaining a senior advisor to the board and to the workshop artists; he passed the light on to Selena, his daugther, who initially learned the art of pastry from him. Passion for great food runs in the Pastranova family...</p>\n\n<img src=\"https://d2aw36oac6sa9o.cloudfront.net/lesbonneschoses/df6c1d87258a5bfadf3479b163fd85c829a5c0b8.jpg\" alt=\"\" width=\"800\" height=\"533\" />\n\n"\
              "<h2>Our main value: our customers' delight</h2>\n\n"\
              "<p>Our every action is driven by the firm belief that there is art in pastry, and that this art is one of the dearest pleasures one can experience.</p>\n\n"\
              "<p>At Les Bonnes Choses, people preparing your macarons are not simply &quot;pastry chefs&quot;: they are &quot;<a href=\"http://localhost/UlfoxUnM0wkXYXba\">ganache specialists</a>&quot;, &quot;<a href=\"http://localhost/UlfoxUnM0wkXYXbQ\">fruit experts</a>&quot;, or &quot;<a href=\"http://localhost/UlfoxUnM0wkXYXbn\">oven instrumentalists</a>&quot;. They are the best people out there to perform the tasks they perform to create your pastry, giving it the greatest value. And they just love to make their specialized pastry skill better and better until perfection.</p>\n\n"\
              "<p>Of course, there is a workshop in each <em>Les Bonnes Choses</em> store, and every pastry you buy was made today, by the best pastry specialists in your country.</p>\n\n"\
              "<p>However, the very difficult art of creating new concepts, juggling with tastes and creating brand new, powerful experiences, is performed every few months, during our &quot;<a href=\"http://localhost/UlfoxUnM0wkXYXbl\">Pastry Art Brainstorms</a>&quot;. During the event, the best pastry artists in the world (some working for <em>Les Bonnes Choses</em>, some not) gather in Paris, and showcase the experiments they've been working on; then, the other present artists comment on the piece, and iterate on it together, in order to make it the best possible masterchief!</p>\n\n"\
              "<p>The session is presided by Jean-Michel Pastranova, who then selects the most delightful experiences, to add it to <em>Les Bonnes Choses</em>'s catalogue.</p>"
      end
      it "returns a correct as_html on a StructuredText with links" do
        @api.form("everything")
          .query(%([[:d = at(document.id, "#{@api.bookmark('about')}")]]))
          .submit(@master_ref)[0]['article.content'].as_html(@link_resolver).gsub("&#39;", "'").should ==
              "<h2>A tale of pastry and passion</h2>\n\n"\
              "<p>As a child, Jean-Michel Pastranova learned the art of fine cuisine from his grand-father, Jacques Pastranova, who was the creator of the &quot;taste-design&quot; art current, and still today an unmissable reference of forward-thinking in cuisine. At first an assistant in his grand-father's kitchen, Jean-Michel soon found himself fascinated by sweet flavors and the tougher art of pastry, drawing his own path in the ever-changing cuisine world.</p>\n\n"\
              "<p>In 1992, the first Les Bonnes Choses store opened on rue Saint-Lazare, in Paris (<a href=\"http://localhost/UlfoxUnM0wkXYXbb\">we're still there!</a>), much to everyone's surprise; indeed, back then, it was very surprising for a highly promising young man with a preordained career as a restaurant chef, to open a pastry shop instead. But soon enough, contemporary chefs understood that Jean-Michel had the drive to redefine a new nobility to pastry, the same way many other kinds of cuisine were being qualified as &quot;fine&quot;.</p>\n\n"\
              "<p>In 1996, meeting an overwhelming demand, Jean-Michel Pastranova opened <a href=\"http://localhost/UlfoxUnM0wkXYXbP\">a second shop on Paris's Champs-Élysées</a>, and <a href=\"http://localhost/UlfoxUnM0wkXYXbr\">a third one in London</a>, the same week! Eventually, Les Bonnes Choses gained an international reputation as &quot;a perfection so familiar and new at the same time, that it will feel like a taste travel&quot; (New York Gazette), &quot;the finest balance between surprise and comfort, enveloped in sweetness&quot; (The Tokyo Tribune), &quot;a renewal of the pastry genre (...), the kind that changed the way pastry is approached globally&quot; (The San Francisco Gourmet News). Therefore, it was only a matter of time before Les Bonnes Choses opened shops in <a href=\"http://localhost/UlfoxUnM0wkXYXbc\">New York</a> (2000) and <a href=\"http://localhost/UlfoxUnM0wkXYXbU\">Tokyo</a> (2004).</p>\n\n"\
              "<p>In 2013, Jean-Michel Pastranova stepped down as the CEO and Director of Workshops, remaining a senior advisor to the board and to the workshop artists; he passed the light on to Selena, his daugther, who initially learned the art of pastry from him. Passion for great food runs in the Pastranova family...</p>\n\n<p class=\"block-img\"><img src=\"https://d2aw36oac6sa9o.cloudfront.net/lesbonneschoses/df6c1d87258a5bfadf3479b163fd85c829a5c0b8.jpg\" alt=\"\" width=\"800\" height=\"533\" /></p>\n\n"\
              "<h2>Our main value: our customers' delight</h2>\n\n"\
              "<p>Our every action is driven by the firm belief that there is art in pastry, and that this art is one of the dearest pleasures one can experience.</p>\n\n"\
              "<p>At Les Bonnes Choses, people preparing your macarons are not simply &quot;pastry chefs&quot;: they are &quot;<a href=\"http://localhost/UlfoxUnM0wkXYXba\">ganache specialists</a>&quot;, &quot;<a href=\"http://localhost/UlfoxUnM0wkXYXbQ\">fruit experts</a>&quot;, or &quot;<a href=\"http://localhost/UlfoxUnM0wkXYXbn\">oven instrumentalists</a>&quot;. They are the best people out there to perform the tasks they perform to create your pastry, giving it the greatest value. And they just love to make their specialized pastry skill better and better until perfection.</p>\n\n"\
              "<p>Of course, there is a workshop in each <em>Les Bonnes Choses</em> store, and every pastry you buy was made today, by the best pastry specialists in your country.</p>\n\n"\
              "<p>However, the very difficult art of creating new concepts, juggling with tastes and creating brand new, powerful experiences, is performed every few months, during our &quot;<a href=\"http://localhost/UlfoxUnM0wkXYXbl\">Pastry Art Brainstorms</a>&quot;. During the event, the best pastry artists in the world (some working for <em>Les Bonnes Choses</em>, some not) gather in Paris, and showcase the experiments they've been working on; then, the other present artists comment on the piece, and iterate on it together, in order to make it the best possible masterchief!</p>\n\n"\
              "<p>The session is presided by Jean-Michel Pastranova, who then selects the most delightful experiences, to add it to <em>Les Bonnes Choses</em>'s catalogue.</p>"
      end
      it "returns a correct as_text on a StructuredText" do
        @api.form("everything")
          .query(%([[:d = at(document.id, "UlfoxUnM0wkXYXbt")]]))
          .submit(@master_ref)[0]['blog-post.body'].as_text.should == "The end of a chapter the beginning of a new one Jean-Michel Pastranova, the founder of Les Bonnes Choses, and creator of the whole concept of modern fine pastry, has decided to step down as the CEO and the Director of Workshops of Les Bonnes Choses, to focus on other projects, among which his now best-selling pastry cook books, but also to take on a primary role in a culinary television show to be announced later this year. \"I believe I've taken the Les Bonnes Choses concept as far as it can go. Les Bonnes Choses is already an entity that is driven by its people, thanks to a strong internal culture, so I don't feel like they need me as much as they used to. I'm sure they are greater ways to come, to innovate in pastry, and I'm sure Les Bonnes Choses's coming innovation will be even more mind-blowing than if I had stayed longer.\" He will remain as a senior advisor to the board, and to the workshop artists, as his daughter Selena, who has been working with him for several years, will fulfill the CEO role from now on. \"My father was able not only to create a revolutionary concept, but also a company culture that puts everyone in charge of driving the company's innovation and quality. That gives us years, maybe decades of revolutionary ideas to come, and there's still a long, wonderful path to walk in the fine pastry world.\""
      end

      it "returns a correct as_text on a StructuredText with a separator" do
        @api.form("everything")
          .query(%([[:d = at(document.id, "UlfoxUnM0wkXYXbt")]]))
          .submit(@master_ref)[0]['blog-post.body'].as_text(' #### ').should == "The end of a chapter the beginning of a new one #### Jean-Michel Pastranova, the founder of Les Bonnes Choses, and creator of the whole concept of modern fine pastry, has decided to step down as the CEO and the Director of Workshops of Les Bonnes Choses, to focus on other projects, among which his now best-selling pastry cook books, but also to take on a primary role in a culinary television show to be announced later this year. #### \"I believe I've taken the Les Bonnes Choses concept as far as it can go. Les Bonnes Choses is already an entity that is driven by its people, thanks to a strong internal culture, so I don't feel like they need me as much as they used to. I'm sure they are greater ways to come, to innovate in pastry, and I'm sure Les Bonnes Choses's coming innovation will be even more mind-blowing than if I had stayed longer.\" #### He will remain as a senior advisor to the board, and to the workshop artists, as his daughter Selena, who has been working with him for several years, will fulfill the CEO role from now on. #### \"My father was able not only to create a revolutionary concept, but also a company culture that puts everyone in charge of driving the company's innovation and quality. That gives us years, maybe decades of revolutionary ideas to come, and there's still a long, wonderful path to walk in the fine pastry world.\""
      end
    end
  end
end
