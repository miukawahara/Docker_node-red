Nodes_Hash={:N8ec3b=>{:type=>"inject", :repeat=>"1", :wires=>[[:Nc0afc]], :inputNodeid=>[], :last_time=>0.0, :flow_controll=>1},
 :Nc0afc=>{:type=>"GPIO", :ReadType=>"ADC", :GPIOType=>"read", :targetPort_digital=>"", :targetPort_ADC=>"7", :wires=>[[:N69594]], :inputNodeid=>[:N8ec3b]},
 :N69594=>{:type=>"function", :wires=>[[]], :inputNodeid=>[:Nc0afc], :flow_endFlg=>0}}
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

def Node_GPIO(node_id)

    input_array = Dataprocessing(node_id,:get)
    Dataprocessing(node_id,:delete)  
    if input_array == []
      return 0
    end

    input = 0

    input_array.each do |input_data|
        if input_data == 0
            return 0
        end
        
    end
    
    if "read" == Nodes_Hash[node_id][:GPIOType]
        if "digital_read" == Nodes_Hash[node_id][:ReadType]
            input = digitalRead(Nodes_Hash[node_id][:targetPort_digital].to_i)
        end

        if "ADC" == Nodes_Hash[node_id][:ReadType]
            adc = ADC.new()
            adc.ch(Nodes_Hash[node_id][:targetPort_ADC].to_i)
            adc.start
            sleep(0.001)
            input = adc.read_v
            adc.stop
        end
        Dataprocessing(node_id,:create,[input])
        return 0
    end

    #後日実装!!
    if "write" == Nodes_Hash[node_id][:GPIOType]

        input_array.each do |input_data|
            if "digital_write" == Nodes_Hash[node_id][:WriteType]
                targetPort = Nodes_Hash[node_id][:targetPort_digital].to_i
                targetPort_mode = Nodes_Hash[node_id][:targetPort_mode].to_i

                if targetPort_mode == 2
                    if input_data != 1
                        digitalWrite(targetPort,0)
                        output = 0
                    else
                        digitalWrite(targetPort,1)
                        output = 1
                    end
                else
                    if input_data != 1
                        next
                    else
                        digitalWrite(targetPort,targetPort_mode)
                        output = 1
                    end
                end
            end

            if "PWM" == Nodes_Hash[node_id][:WriteType]
                PWM.new()
                PWM.pin(Nodes_Hash[node_id][:targetPort_PWM].to_i)
                PWM.start(Nodes_Hash[node_id][:PWM_num].to_i)
                PWM.cycle(Nodes_Hash[node_id][:time].to_i,Nodes_Hash[node_id][:double].to_i)
                PWM.rate(Nodes_Hash[node_id][:rate].to_i,Nodes_Hash[node_id][:PWM_num].to_i)
            end

        end
        return 0
    end
end

#this is function Node
def FunctionNode_N69594(msg)
data = msg 

puts(" | ")
#puts data
#puts msg

    data = (3.3 / data)-1
    temp = 1.0/(Math.log(data)/4275+1/298.15)-273.15
    sleep(1)
    puts("ans:" + temp.to_s)

return msg
end

def Node_function(node_id)
    input_array = Dataprocessing(node_id,:get)
    Dataprocessing(node_id,:delete)
    if input_array == []
        return 0
    end
    output = 0

    input_array.each do |input_data|
 
    
        if node_id == :N69594
            output = FunctionNode_N69594(input_data)
        end
        
    end
    Dataprocessing(node_id,:create,[output])
end
    

while true
Node_inject(:N8ec3b)
Node_GPIO(:Nc0afc)
Node_function(:N69594)
sleep(0.01)
end