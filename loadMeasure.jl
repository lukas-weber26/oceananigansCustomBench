

#runs a thing writes a file 
function cpu_usage_track(fileName)
        st = read("/proc/stat", String)
        a = split(st, '\n')

        for i in a
                item = split(i, ' ')
                if ("cpu" == item[1])
                        user = parse(Int64, item[3])
                        nice = parse(Int64, item[4])
                        system = parse(Int64, item[5])
                        idle = parse(Int64, item[6])
                        iowait = parse(Int64, item[7])
                        irq = parse(Int64, item[8])
                        softirq = parse(Int64, item[9])
                        total = user + nice + system + idle + iowait + irq + softirq
                        outputStr = string(100 * user / total) * "\t" * string(100 * nice / total) * "\t" * string(100 * system / total) * "\t" * string(100 * idle / total) * "\t" * string(100 * iowait / total) * "\t" * string(100 * irq / total) * "\t" * string(100 * softirq / total)

                        open(fileName, "a") do file
                                write(file, outputStr)
                        end

                end
        end
end






