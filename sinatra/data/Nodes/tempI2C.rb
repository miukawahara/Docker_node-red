def Node_tempI2C(node_id)
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
            ans = output[1] | ((output[0] & 0x1f) << 8)
            ans = (ans.to_f)* 0.0625
            puts("ans:"+ans.to_s+"\r\n")
            sleep(5)
        end

        if rule[:de] != ""
            sleep_ms(rule[:de].to_i)
        end
    end
    Dataprocessing(node_id,:create,[output])
end