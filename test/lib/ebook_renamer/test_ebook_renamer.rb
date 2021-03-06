require_relative "../../test_helper"
describe EbookRenamer do
  include EbookRenamer
  before do
    @sample = meta("./test/fixtures/ebooks/demo1.pdf")
  end

  context "#meta" do
    it "raises error on invalid input" do
      -> { meta("invalid-filename") }.must_raise RuntimeError
    end

    it "returns valid valid input" do
      @sample.wont_be_nil
    end
  end

  context "#meta_to_hash" do
    it "returns empty hash" do
      meta_to_hash(nil).must_be_empty
    end
    it "returns non-empty hash" do
      hash = meta_to_hash(@sample)
      hash.wont_be_empty
    end

    describe "invalid format" do
      it "return empty hash" do
        meta_to_hash("aa bb").must_equal({})
      end
    end

    describe "valid format" do
      # extract list of 'key' : 'value' from the input
      let(:sample) do
        <<-END
        Aaaa : BBbb
        CcCc : DddD
        EeeE : FFFF:gggg
        hhhh : iiii:JJJJ:kkkk
        END
      end

      let(:result) { meta_to_hash(sample) }

      it "returns proper type for result" do
        result.must_be_instance_of Hash
      end

      it "uses lowercase for result keys" do
        result.keys.must_equal %w[aaaa cccc eeee hhhh]
      end

      it "retains original cases for result values" do
        result.values.must_equal ["BBbb", "DddD", "FFFF:gggg", "iiii:JJJJ:kkkk"]
      end
    end
  end

  context "#formatted_name" do
    describe "invalid parameters" do
      it "raises exception on nil arguments" do
        -> { formatted_name({}, nil) }.must_raise ArgumentError
      end
      it "raises exception on empty hash" do
        -> { formatted_name({}, {}) }.must_raise RuntimeError
      end
    end
    describe "valid parameters" do
      it "returns result based on single key" do
        formatted_name({"title"      => "The Firm",
                        "author"     => "John Grisham",
                        "page count" => 399},
                       keys: ["title"]).must_equal "The Firm"
      end
      it "returns result based for multiple keys" do
        formatted_name({"title"      => "The Firm",
                        "author"     => "John Grisham",
                        "page count" => "399"},
                       sep_char: ":",
                       keys: ["title",
                              "author",
                              "page count"]).must_equal "The Firm:John Grisham:399"
      end
    end
  end
end
