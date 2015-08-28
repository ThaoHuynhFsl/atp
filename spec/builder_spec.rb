require 'spec_helper'

describe 'The builder API' do
  it 'is alive' do
    prog = ATP::Program.new
    flow = prog.flow(:sort1)
    flow.program.should == prog
    flow.raw.should be
  end

  it "tests can be added" do
    flow = ATP::Program.new.flow(:sort1) 
    flow.test :test1, on_fail: { bin: 5 }
    flow.test :test2, on_fail: { bin: 6, continue: true }
    flow.raw.should ==
      s(:flow,
        s(:test,
          s(:name, "test1"),
          s(:on_fail,
            s(:bin, 5))),
        s(:test,
          s(:name, "test2"),
          s(:on_fail,
            s(:bin, 6),
            s(:continue))))
  end

  it "conditions can be specified" do
    flow = ATP::Program.new.flow(:sort1) 
    flow.test :test1, id: :t1
    flow.test :test2, id: "T2" # Test that strings will be accepted for IDs
    flow.test :test3, conditions: { if_enabled: "bitmap" }
    flow.test :test4, conditions: { unless_enabled: "bitmap", if_failed: :t1 }
    flow.raw.should ==
      s(:flow,
        s(:test,
          s(:name, "test1"),
          s(:id, :t1)),
        s(:test,
          s(:name, "test2"),
          s(:id, :t2)),
        s(:flow_flag, "bitmap", true,
          s(:test,
            s(:name, "test3"))),
        s(:test_result, :t1, false,
          s(:flow_flag, "bitmap", false,
            s(:test,
              s(:name, "test4")))))
  end

  it "groups can be added" do
    flow = ATP::Program.new.flow(:sort1) 
    flow.test :test1
    flow.test :test2, group: "g1"
    flow.test :test3, group: "g1"
    flow.group "g2" do
      flow.test :test4
      flow.test :test5
      flow.test :test6, groups: ["g3", "g4"]
    end
    flow.ast.should ==
      s(:flow,
        s(:test,
          s(:name, "test1")),
        s(:group, "g1",
          s(:test,
            s(:name, "test2")),
          s(:test,
            s(:name, "test3"))),
        s(:group, "g2",
          s(:test,
            s(:name, "test4")),
          s(:test,
            s(:name, "test5")),
          s(:group, "g4",
            s(:group, "g3",
              s(:test,
                s(:name, "test6"))))))

  end
end