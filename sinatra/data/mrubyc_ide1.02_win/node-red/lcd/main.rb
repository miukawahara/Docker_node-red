Nodes_Hash={:N8ec3b=>{:type=>"inject", :repeat=>"1", :wires=>[[:N43241]], :inputNodeid=>[], :last_time=>0.0, :flow_controll=>1},
 :N43241=>{:type=>"I2C", :ad=>98, :rules=>[{:t=>"W", :v=>0, :c=>0, :de=>"1"}, {:t=>"W", :v=>8, :c=>255, :de=>"1"}, {:t=>"W", :v=>1, :c=>32, :de=>"1"}, {:t=>"W", :v=>4, :c=>255, :de=>"1"}, {:t=>"W", :v=>3, :c=>255, :de=>"1"}, {:t=>"W", :v=>2, :c=>255, :de=>"1"}], :wires=>[[:N59adb]], :inputNodeid=>[:N8ec3b]},
 :N59adb=>{:type=>"I2C", :ad=>62, :rules=>[{:t=>"W", :v=>128, :c=>2, :de=>"5"}, {:t=>"W", :v=>128, :c=>12, :de=>"5"}, {:t=>"W", :v=>64, :c=>100, :de=>"1"}], :wires=>[[]], :inputNodeid=>[:N43241], :flow_endFlg=>0}}
DatasBuffer = []

def Dataprocessing(node_id, mode, output = "")
    /get:データの取り出し deleet:自分宛のデータの削除 create:次ノード宛のデータの作成/
    get_datas = []
    if mode == :get
        DatasBuffer.each do |data|
            if node_id == data[1]
                get_datas << data[2]
            end
        end
        if Nodes_Hash[node_id][:inputNodeid].length > get_datas.length
            get_datas = []
        end
    end
    index = 0
    if mode == :delete
        DatasBuffer.each do |data|
            if node_id == data[1]
                DatasBuffer.delete_at(index)
            end
            index += 1
        end
    end
    if mode == :create
        if Nodes_Hash[node_id].has_key?(:flow_endFlg)
            return 0
        end
        output_index = 0
        Nodes_Hash[node_id][:wires].each do |wires|
            wires.each do |wire|
                index = 0
                DatasBuffer.each do |data|
                    if [node_id ,wire] == [data[0], data[1]] 
                        DatasBuffer.delete_at(index)
                        break
                    end
                    index += 1
                end
                DatasBuffer << [node_id ,wire, output[output_index]]
            end
            output_index += 1
        end
    end
    return get_datas
end
def Node_inject(node_id)
    if Nodes_Hash[node_id][:repeat] != ""
        if GetTime(node_id) == 1
            if Nodes_Hash[node_id][:flow_controll] == 1
                Nodes_Hash[node_id][:flow_controll] = 0
            elsif Nodes_Hash[node_id][:flow_controll] == 0
                Nodes_Hash[node_id][:flow_controll] = 1
            end
            Dataprocessing(node_id,:create,[Nodes_Hash[node_id][:flow_controll]])
        end
        return 0
    else
        Dataprocessing(node_id,:create,[1])
        return 0
    end
end

def GetTime(node_id)

    if Nodes_Hash[node_id][:type] == "inject"
        repeat_time = Nodes_Hash[node_id][:repeat].to_f
    end

    if Nodes_Hash[node_id][:type] == "delay"
        repeat_time = Nodes_Hash[node_id][:timeout].to_f
    end

    run_time = VM.tick()/1000.0
    last_time = Nodes_Hash[node_id][:last_time]
    last_time = run_time - last_time

    if last_time >= repeat_time
        Nodes_Hash[node_id][:last_time] = run_time
        return 1
    else
        return 0
    end
end

def Node_I2C(node_id)
    /データ有無の確認/
    input_array = Dataprocessing(node_id,:get)
    Dataprocessing(node_id,:delete)
    if input_array == []
        return 0
    end
    input_array.each do |input_data|
        if input_data == 0
            return 0
        end
    end

    sraveAd = Nodes_Hash[node_id][:ad].to_i
    output = []
    Nodes_Hash[node_id][:rules].each do |rule|
        if rule[:t] == "W"
            I2C.write(sraveAd, rule[:v].to_i, rule[:c].to_i)
        else
            output = I2C.read(sraveAd, rule[:v].to_i, rule[:b].to_i)
        end

        if rule[:de] != ""
            sleep_ms(rule[:de].to_i)
        end
    end
    Dataprocessing(node_id,:create,[output])
end

while true
Node_inject(:N8ec3b)
Node_I2C(:N43241)
Node_I2C(:N59adb)
sleep(0.01)
end