Nodes_Hash={:N8ec3b=>{:type=>"inject", :repeat=>"1", :wires=>[[:N22972]], :inputNodeid=>[], :last_time=>0.0, :flow_controll=>1},
 :Nf27df=>{:type=>"LED", :LEDtype=>"GPIO", :targetPort=>"0", :targetPort_mode=>"2", :onBoardLED=>"", :wires=>[], :inputNodeid=>[:N22972]},
 :N22972=>{:type=>"Button", :onBoardButton=>"1", :targetPort=>"16", :selectPull=>"0", :wires=>[[:Nf27df]], :inputNodeid=>[:N8ec3b]}}
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

#this is LED Node

def GPIO_digital_mode2(node_id,input)
    if input == 0
        digitalWrite(Nodes_Hash[node_id][:targetPort].to_i,0)
    elsif input == 1
        digitalWrite(Nodes_Hash[node_id][:targetPort].to_i,1)
    end
 end
    
def Node_LED(node_id)
    input_array = Dataprocessing(node_id,:get)
    Dataprocessing(node_id,:delete)  
    if input_array == []
      return 0
    end
      
    input_array.each do |input|
    
            if Nodes_Hash[node_id][:targetPort_mode] == "2" && Nodes_Hash[node_id][:LEDtype] == "GPIO"
                GPIO_digital_mode2(node_id,input)
            end

    end
end


def Node_Button(node_id)
  input_array = Dataprocessing(node_id,:get)
  if input_array == []
    return 0
  end
  Dataprocessing(node_id,:delete)  

  input = 0

  input_array.each do |input_data|
    if input_data != 1
      Dataprocessing(node_id,:create,[0])
      return 0
    end
  end

  if Nodes_Hash[node_id][:onBoardButton] == "1"
    input = sw()
    if input == 1
      input = 0
    else
      input = 1
    end
  else
    input = digitalRead(Nodes_Hash[node_id][:targetPort].to_i)
  end

  Dataprocessing(node_id,:create,[input])
end

pinMode(16,1)
pinPull(16,0)
while true
Node_inject(:N8ec3b)
Node_LED(:Nf27df)
Node_Button(:N22972)
sleep(0.01)
end