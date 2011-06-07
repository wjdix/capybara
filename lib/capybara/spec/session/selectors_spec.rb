shared_examples_for "selectors" do
  describe '#find' do
    before do
      @session.visit('/with_html')
    end

    context "with custom selector" do
      it "should use the custom selector" do
        Capybara.add_selector(:monkey) do
          xpath { |name| ".//*[@id='#{name}_monkey']" }
        end
        @session.find(:monkey, 'john').text.should == 'Monkey John'
        @session.find(:monkey, 'paul').text.should == 'Monkey Paul'
      end
    end

    context "with custom selector with :for option" do
      it "should use the selector when it matches the :for option" do
        Capybara.add_selector(:monkey) do
          xpath { |num| ".//*[contains(@id, 'monkey')][#{num}]" }
          match { |value| value.is_a?(Fixnum) }
        end
        @session.find(:monkey, '2').text.should == 'Monkey Paul'
        @session.find(1).text.should == 'Monkey John'
        @session.find(2).text.should == 'Monkey Paul'
        @session.find('//h1').text.should == 'This is a test'
      end
    end

    context "with custom selector with failure_message option" do
      it "should raise an error with the failure message if the element is not found" do
        Capybara.add_selector(:monkey) do
          xpath { |num| ".//*[contains(@id, 'monkey')][#{num}]" }
          failure_message { |node, selector| node.all(".//*[contains(@id, 'monkey')]").map { |node| node.text }.sort.join(', ') }
        end
        running do
          @session.find(:monkey, '14').text.should == 'Monkey Paul'
        end.should raise_error(Capybara::ElementNotFound, "Monkey John, Monkey Paul")
      end

      it "should pass the selector as the second argument" do
        Capybara.add_selector(:monkey) do
          xpath { |num| ".//*[contains(@id, 'monkey')][#{num}]" }
          failure_message { |node, selector| selector.name.to_s + ': ' + selector.locator + ' - ' + node.all(".//*[contains(@id, 'monkey')]").map { |node| node.text }.sort.join(', ') }
        end
        running do
          @session.find(:monkey, '14').text.should == 'Monkey Paul'
        end.should raise_error(Capybara::ElementNotFound, "monkey: 14 - Monkey John, Monkey Paul")
      end
    end

    context "with custom selector with extension", :focus => true do
      it "should extend the found element with the given methods" do
        thing = Module.new do
          def upcased_text
            text.upcase
          end
        end
        Capybara.add_selector(:fdsfdsfds) do
          xpath { |num| ".//*[contains(@id, 'monkey')][#{num}]" }
          extensions thing do
            def reversed_text
              text.reverse
            end
          end
        end

        @session.find(:monkey, '2').upcased_text.should == 'MONKEY PAUL'
        @session.find(:monkey, '2').reversed_text.should == 'aulP yeknoM'
      end
    end
  end
end
